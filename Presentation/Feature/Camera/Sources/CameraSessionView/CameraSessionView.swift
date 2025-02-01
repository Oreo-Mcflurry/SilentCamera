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
        viewModel.switchFlash = controller.switchFlash(isOn:)
        viewModel.switchGrid = controller.switchGrid(isOn:)
        viewModel.switchCamera = controller.switchCamera(isBack:)
        viewModel.capturePhoto = controller.capture
        viewModel.brightness = controller.setBrightness(_:)
        return controller
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}
}

final class CameraViewController: UIViewController {
    private enum Constants {
        static let focusViewTag = 999
        static let focusViewSize: CGFloat = 100
        static let focusViewBorderWidth: CGFloat = 1
        static let focusViewBorderColor = UIColor.yellow.cgColor
        
        static let gridLayerName = "CameraGridLayer"
        static let gridLayerStrokeColor = UIColor.white.withAlphaComponent(0.7).cgColor
        static let gridLayerLineWidth: CGFloat = 0.5
    }
    
    private var currentPosition: AVCaptureDevice.Position = .back
    private var captureSession = AVCaptureSession()
    private var photoOutput = AVCapturePhotoOutput()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
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
        
            cancellable = imageSubject.sink { [weak self] image in
                promise(.success(image))
                self?.cancellable?.cancel()
            }
        }
    }
    
    func switchGrid(isOn: Bool) {
        isOn ? addCameraGrid() : removeCameraGrid()
    }
    
    func switchCamera(isBack: Bool) {
        setupCamera(isBack ? .back : .front)
    }
    
    func switchFlash(isOn: Bool) {
        setFlash(isOn)
    }
    
    func setBrightness(_ value: Float) {
        handleBrightness(value)
    }
}

// MARK: - Brightness Extension
extension CameraViewController {
    private func handleBrightness(_ value: Float) {
        guard let device else { return }
                
        try? device.lockForConfiguration()
        
        if device.isExposureModeSupported(.custom) {
            device.exposureMode = .custom
            device.setExposureTargetBias(value, completionHandler: nil)
        }
        
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
        
        let path = UIBezierPath()
        let width = view.bounds.width
        let height = view.bounds.height
        
        let columnSpacing = width / 3
        let rowSpacing = height / 3

        // 수직선
        for index in 1..<3 {
            let xPosition = CGFloat(index) * columnSpacing
            path.move(to: CGPoint(x: xPosition, y: 0))
            path.addLine(to: CGPoint(x: xPosition, y: height))
        }
        
        // 수평선
        for index in 1..<3 {
            let yPosition = CGFloat(index) * rowSpacing
            path.move(to: CGPoint(x: 0, y: yPosition))
            path.addLine(to: CGPoint(x: width, y: yPosition))
        }

        gridLayer.path = path.cgPath
        view.layer.addSublayer(gridLayer)
    }
    
    func removeCameraGrid() {
        view.layer.sublayers?.removeAll { $0.name == Constants.gridLayerName }
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
        guard let cgImage = photo.cgImageRepresentation(),
              let _ = photo.fileDataRepresentation() else {
            imageSubject.send(nil)
            return
        }
        
        let image = UIImage(cgImage: cgImage)
        imageSubject.send(image)
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
        device.torchMode = isOn ? .on : .off
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
        try? device.lockForConfiguration()
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
            let newPosition: AVCaptureDevice.Position = await self.currentPosition == .back ? .front : .back
            await MainActor.run {
                self.currentPosition = newPosition
                
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
