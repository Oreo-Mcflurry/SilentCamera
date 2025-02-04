//
//  CameraView.swift
//  Camera
//
//  Created by A_Mcflurry on 1/31/25.
//

import SwiftUI
import UIKit

import AVFoundation
import ImageIO
import Combine

import Extension

struct CameraSessionView: UIViewControllerRepresentable {
    @ObservedObject var viewModel: CameraViewModel
    
    func makeUIViewController(context: Context) -> CameraViewController {
        let controller = CameraViewController()
        viewModel.configureActions(
            switchFlash: controller.switchFlash(isOn:),
            switchGrid: controller.switchGrid(isOn:),
            switchCamera: controller.switchCamera(isBack:),
            capturePhoto: controller.capture,
            brightness: controller.setBrightness(_:),
            updateRatio: controller.updateCameraRatio,
            zoomScaleSubject: controller.zoomScaleSubject
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) { }
}

final class CameraViewController: UIViewController {
    private enum Constants {
        static let focusViewTag = 999
        static let focusViewSize: CGFloat = 100
        static let focusViewBorderWidth: CGFloat = 1
        static let focusViewBorderColor = UIColor.yellow.cgColor
        
        static let cornerLength: CGFloat = 20.0
        static let cornerLayerName = "CameraCornerLayer"
        
        static let gridLayerName = "CameraGridLayer"
        static let gridLayerStrokeColor = UIColor.white.withAlphaComponent(0.7).cgColor
        static let gridLayerLineWidth: CGFloat = 0.8
        
        static let maxZoomScale: CGFloat = 100.0
        static let minZoomScale: CGFloat = 1.0
    }
    
    private var currentPosition: AVCaptureDevice.Position = .back
    private var captureSession = AVCaptureSession()
    private var photoOutput = AVCapturePhotoOutput()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    let zoomScaleSubject = PassthroughSubject<CGFloat, Never>()
    let brightnessSubject = PassthroughSubject<Float, Never>()
    
    private let imageSubject = PassthroughSubject<UIImage?, Never>()
    private var cancellable: AnyCancellable?
    
    private let focusView: UIView = {
        let focusView = UIView(frame: CGRect(x: 0, y: 0, width: Constants.focusViewSize, height: Constants.focusViewSize))
        focusView.backgroundColor = .clear
        focusView.layer.borderColor = Constants.focusViewBorderColor
        focusView.layer.borderWidth = Constants.focusViewBorderWidth
        focusView.tag = Constants.focusViewTag
        return focusView
    }()
    
    private var device: AVCaptureDevice? {
        switch currentPosition {
        case .back:
            return AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        case .front:
            return AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
        default:
            return nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTapToFocusGesture()
        addPinchToZoomGesture()
        addExposureControlGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupCamera()
    }
}

// MARK: - UseCases Extension
extension CameraViewController {
    func capture() -> Future<UIImage?, Never> {
        Future { [weak self] promise in
            guard let self else { return }
            capturePhoto()
            
            cancellable = imageSubject.sink(with: self) { owner, image in
                promise(.success(image))
                owner.cancellable?.cancel()
            }
        }
    }
    
    func switchGrid(isOn: Bool) {
        isOn ? addCameraGrid() : removeCameraGrid()
    }
    
    func switchCamera(isBack: Bool) {
        currentPosition = isBack ? .back : .front
        switchCamera()
    }
    
    func switchFlash(isOn: Bool) {
        setFlash(isOn)
    }
    
    func setBrightness(_ value: Float) {
        adjustExposure(movement: value)
    }
}

// MARK: - Ratio Extensiom
extension CameraViewController {
    func updateCameraRatio() {
        Task { @MainActor in
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.25)
            CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .easeInEaseOut))
            
            previewLayer?.frame = self.view.bounds
            updateCornerGuidelines()
            updateCameraGrid()
            
            CATransaction.commit()
        }
    }
}

// MARK: - Brightness Extension
extension CameraViewController {
    private func addExposureControlGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleExposureControl(_:)))
        view.addGestureRecognizer(panGesture)
    }
    
    @objc private func handleExposureControl(_ gesture: UIPanGestureRecognizer) {
        guard let device else { return }
        
        let translationY = gesture.translation(in: view).y
        let movementFactor = Float(translationY / view.bounds.height) * 2
        
        guard let _ = try? device.lockForConfiguration() else {
            device.unlockForConfiguration()
            return
        }
        
        switch gesture.state {
        case .changed:
            adjustExposure(movement: movementFactor)
        case .ended:
            gesture.setTranslation(.zero, in: view)
        default:
            break
        }
        
        device.unlockForConfiguration()
    }
    
    private func adjustExposure(movement: Float) {
        guard let device else { return }
        
        let currentISO = device.iso
        let currentBias = device.exposureTargetBias
        
        // ISO 조정
        let targetISO = max(device.activeFormat.minISO, min(currentISO - movement * 100, device.activeFormat.maxISO))
        device.setExposureModeCustom(duration: device.exposureDuration, iso: targetISO, completionHandler: nil)
        
        // 노출 보정 값 조정
        let targetBias = max(device.minExposureTargetBias, min(currentBias - movement, device.maxExposureTargetBias))
        device.setExposureTargetBias(targetBias, completionHandler: nil)
    }
}

// MARK: - Camera Zoom Extension
extension CameraViewController {
    private func addPinchToZoomGesture() {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchCamera(_:)))
        view.addGestureRecognizer(pinchGesture)
    }
    
    @objc private func handlePinchCamera(_ pinch: UIPinchGestureRecognizer) {
        guard let device = self.device else { return }
        
        var initialScale: CGFloat = device.videoZoomFactor
        let minZoomScale: CGFloat = Constants.minZoomScale // 광각을 최솟값으로 설정
        
        guard let _ = try? device.lockForConfiguration() else {
            device.unlockForConfiguration()
            return
        }
        
        if pinch.state == .began {
            initialScale = device.videoZoomFactor
        } else {
            let targetScale = min(max(initialScale * pinch.scale, minZoomScale), Constants.maxZoomScale)
            device.videoZoomFactor = targetScale
            zoomScaleSubject.send(targetScale)
        }
        
        pinch.scale = 1.0
        device.unlockForConfiguration()
    }
    
    func setZoom(to scale: CGFloat) {
        guard let device = self.device else { return }
        guard let _ = try? device.lockForConfiguration() else {
            device.unlockForConfiguration()
            return
        }
        let clampedScale = min(max(scale, Constants.minZoomScale), Constants.maxZoomScale)
        zoomScaleSubject.send(clampedScale)
        device.videoZoomFactor = clampedScale
        device.unlockForConfiguration()
    }
}

// MARK: - Camera Grid Extension
extension CameraViewController {
    func addCameraGrid() {
        let gridLayer = CAShapeLayer()
        gridLayer.strokeColor = Constants.gridLayerStrokeColor
        gridLayer.lineWidth = Constants.gridLayerLineWidth
        gridLayer.name = Constants.gridLayerName
        
        let path = createGridPath()
        
        gridLayer.path = path.cgPath
        view.layer.addSublayer(gridLayer)
    }
    
    private func updateCameraGrid() {
        guard let gridLayer = view.layer.sublayers?.first(where: { $0.name == Constants.gridLayerName }) as? CAShapeLayer else { return }
        let path = createGridPath()
        applyPathAnimation(to: gridLayer, newPath: path.cgPath)
    }
    
    func removeCameraGrid() {
        view.layer.sublayers?.removeAll { $0.name == Constants.gridLayerName }
    }
    
    private func createGridPath() -> UIBezierPath {
        let columns = 3
        let rows = 3
        
        let path = UIBezierPath()
        let width = view.bounds.width
        let height = view.bounds.height
        
        let columnSpacing = width / CGFloat(columns)
        let rowSpacing = height / CGFloat(rows)
        
        // 수직선 그리기
        for index in 1..<columns {
            let xPosition = CGFloat(index) * columnSpacing
            path.move(to: CGPoint(x: xPosition, y: 0))
            path.addLine(to: CGPoint(x: xPosition, y: height))
        }
        
        // 수평선 그리기
        for index in 1..<rows {
            let yPosition = CGFloat(index) * rowSpacing
            path.move(to: CGPoint(x: 0, y: yPosition))
            path.addLine(to: CGPoint(x: width, y: yPosition))
        }
        
        return path
    }
    
    private func addCornerGuidelines() {
        let cornerLayer = CAShapeLayer()
        cornerLayer.strokeColor = Constants.gridLayerStrokeColor
        cornerLayer.lineWidth = Constants.gridLayerLineWidth
        cornerLayer.name = Constants.cornerLayerName
        
        let path = createCornerPath()
        
        cornerLayer.path = path.cgPath
        
        cornerLayer.backgroundColor = UIColor.clear.cgColor
        cornerLayer.fillColor = UIColor.clear.cgColor
        
        view.layer.addSublayer(cornerLayer)
    }
    
    private func updateCornerGuidelines() {
        // 기존 코너 레이어 찾기
        guard let cornerLayer = view.layer.sublayers?.first(where: { $0.name == Constants.cornerLayerName }) as? CAShapeLayer else { return }
        let path = createCornerPath()
        
        // 애니메이션 설정
        applyPathAnimation(to: cornerLayer, newPath: path.cgPath)
    }
    
    private func createCornerPath() -> UIBezierPath {
        let width = view.bounds.width
        let height = view.bounds.height
        
        let path = UIBezierPath()
        let cornerLength: CGFloat = Constants.cornerLength

        // 좌상단 (ㄴ)
        path.move(to: CGPoint(x: 0, y: cornerLength))
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: cornerLength, y: 0))

        // 우상단 (ㄱ)
        path.move(to: CGPoint(x: width - cornerLength, y: 0))
        path.addLine(to: CGPoint(x: width, y: 0))
        path.addLine(to: CGPoint(x: width, y: cornerLength))

        // 좌하단 (ㄱ)
        path.move(to: CGPoint(x: 0, y: height - cornerLength))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.addLine(to: CGPoint(x: cornerLength, y: height))

        // 우하단 (ㄴ)
        path.move(to: CGPoint(x: width - cornerLength, y: height))
        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: width, y: height - cornerLength))

        return path
    }
    
    private func applyPathAnimation(to layer: CAShapeLayer, newPath: CGPath, duration: CFTimeInterval = 0.25) {
        let animation = CABasicAnimation(keyPath: "path")
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.fromValue = layer.path
        animation.toValue = newPath
        
        layer.path = newPath
        layer.add(animation, forKey: "pathAnimation")
    }
}

// MARK: - Capture Extension
extension CameraViewController: AVCapturePhotoCaptureDelegate {
    private func capturePhoto() {
        guard captureSession.isRunning else { return }
        
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .off
                
        showFlashEffect()
        
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    // MARK: 무음 처리
    func photoOutput(_ output: AVCapturePhotoOutput, willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        AudioServicesDisposeSystemSoundID(1108)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        AudioServicesDisposeSystemSoundID(1108)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            imageSubject.send(nil)
            return
        }
        
        // PreviewLayer의 bounds를 이미지 좌표로 변환
        guard let cgImage = cropImageToRatio(image, ratio: 4/3) else {
            imageSubject.send(image)
            return
        }
                
        imageSubject.send(cgImage)
    }
    
    private func showFlashEffect() {
        let flashView = UIView(frame: self.view.bounds)
        flashView.backgroundColor = UIColor.black
        flashView.alpha = 0.0
        self.view.addSubview(flashView)
        
        // 애니메이션 추가
        UIView.animate(withDuration: 0.1, animations: {
            flashView.alpha = 1
        }) { _ in
            // 애니메이션 끝나면 사라짐
            UIView.animate(withDuration: 0.1, animations: {
                flashView.alpha = 0.0
            }) { _ in
                flashView.removeFromSuperview() // 뷰 제거
            }
        }
    }
}

// MARK: - Flash Extension
extension CameraViewController {
    private func setFlash(_ isOn: Bool) {
        guard let device else { return }
        guard let _ = try? device.lockForConfiguration() else {
            device.unlockForConfiguration()
            return
        }
        device.torchMode = isOn ? .on : .off
        device.unlockForConfiguration()
    }
}

// MARK: - Focus Extension
extension CameraViewController {
    // MARK: Focus Gesture Add
    private func addTapToFocusGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleFocusTap(_:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: Focus Feature
    @objc private func handleFocusTap(_ sender: UITapGestureRecognizer) {
        guard sender.state == .ended else { return }
        guard let preView = self.view else { return }
        guard let device else { return }
        
        let thisFocusPoint = sender.location(in: preView)
        focusAnimationAt(thisFocusPoint)
        let focus_x = thisFocusPoint.x / preView.frame.size.width
        let focus_y = thisFocusPoint.y / preView.frame.size.height
        
        guard device.isFocusModeSupported(.autoFocus) && device.isFocusPointOfInterestSupported else { return }
        
        guard let _ = try? device.lockForConfiguration() else {
            device.unlockForConfiguration()
            return
        }
        
        device.focusMode = .autoFocus
        device.focusPointOfInterest = CGPoint(x: focus_x, y: focus_y)
        
        if (device.isExposureModeSupported(.autoExpose) && device.isExposurePointOfInterestSupported) {
            device.exposureMode = .autoExpose;
            device.exposurePointOfInterest = CGPoint(x: focus_x, y: focus_y);
        }
        
        device.unlockForConfiguration()
    }
    
    // MARK: Focus Animation
    fileprivate func focusAnimationAt(_ point: CGPoint) {
        guard let preView = self.view else { return }
        if let alreadyHasFocusView: UIView = self.view.viewWithTag(Constants.focusViewTag) {
            alreadyHasFocusView.removeFromSuperview()
        }
        
        focusView.alpha = 1
        focusView.center = point
        focusView.center = point
        preView.addSubview(focusView)
        
        focusView.transform = CGAffineTransform(scaleX: 2, y: 2)
        
        UIView.animate(
            withDuration: 0.25,
            delay: 0.0,
            options: .curveEaseInOut,
            animations: {
                self.focusView.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
            },
            completion: { _ in
                UIView.animate(withDuration: 0.25, delay: 1.5) {
                    self.focusView.alpha = 0.4
                }
            }
        )
    }
}

// MARK: - Camera Setup Extension
extension CameraViewController {
    private func setupCamera(_ type: AVCaptureDevice.Position = .back) {
        Task.detached {
            guard let device = await self.device,
                  let input = try? AVCaptureDeviceInput(device: device) else { return }
            
            await self.captureSession.beginConfiguration()
            
            if await self.captureSession.canAddInput(input) {
                await self.captureSession.addInput(input)
            }
            
            if await self.captureSession.canAddOutput(self.photoOutput) {
                await self.captureSession.addOutput(self.photoOutput)
            }
            
            await MainActor.run {
                let previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
                previewLayer.videoGravity = .resizeAspectFill
                previewLayer.frame = self.view.bounds
                self.view.layer.addSublayer(previewLayer)
                self.previewLayer = previewLayer
            }
            
            await self.captureSession.commitConfiguration()
            await self.captureSession.startRunning()
            
            await MainActor.run {
                self.addCornerGuidelines()
            }
        }
    }
    
    // MARK: Camera Switch Feature
    private func switchCamera() {
        Task.detached {
            // 현재 세션의 입력 제거
            await self.captureSession.beginConfiguration()
            
            if let currentInput = await self.captureSession.inputs.first as? AVCaptureDeviceInput {
                await self.captureSession.removeInput(currentInput)
            }
            
            // 새로운 카메라 입력 생성
            await MainActor.run {
                guard let newCamera = self.device,
                      let newInput = try? AVCaptureDeviceInput(device: newCamera) else {
                    self.captureSession.commitConfiguration()
                    return
                }
                
                if self.captureSession.canAddInput(newInput) {
                    self.captureSession.addInput(newInput)
                }
            }
            await self.captureSession.commitConfiguration()
        }
    }
}

func cropImageToRatio(_ image: UIImage, ratio: CGFloat) -> UIImage? {
    // 디버깅을 위한 출력
    print("Original image size: \(image.size)")
    print("Original orientation: \(image.imageOrientation)")
    
    // CGImage가 없는 경우 early return
    guard let inputCGImage = image.cgImage else {
        print("Failed to get cgImage")
        return nil
    }
    
    // 실제 이미지 크기 사용 (CGImage 기준)
    let imageWidth = CGFloat(inputCGImage.width)
    let imageHeight = CGFloat(inputCGImage.height)
    
    print("CGImage size: width = \(imageWidth), height = \(imageHeight)")
    
    // ratio에 따른 target height 계산 (width 기준)
    let targetHeight = imageWidth / ratio
    let heightToCrop = max(0, (imageHeight - targetHeight) / 2)
    
    let cropRect = CGRect(
        x: 0,
        y: heightToCrop,
        width: imageWidth,
        height: targetHeight
    )
    
    print("Crop rect: \(cropRect)")
    
    if let cgImage = inputCGImage.cropping(to: cropRect) {
        return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
    } else {
        print("Cropping failed")
        return nil
    }
}
// UIImage 방향 확장
extension UIImage.Orientation {
    var isPortrait: Bool {
        switch self {
        case .left, .right, .leftMirrored, .rightMirrored:
            return true
        default:
            return false
        }
    }
}
