//
//  CameraView.swift
//  Camera
//
//  Created by A_Mcflurry on 1/31/25.
//

import SwiftUI
import UIKit
import AVFoundation

struct CameraView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> CameraViewController {
        let controller = CameraViewController()
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, CameraViewControllerDelegate {
        func didTapToFocus(at point: CGPoint) {
            print("Focus at: \(point)")
        }
    }
}

protocol CameraViewControllerDelegate: AnyObject {
    func didTapToFocus(at point: CGPoint)
}

class CameraViewController: UIViewController {
    var captureSession = AVCaptureSession()
    weak var delegate: CameraViewControllerDelegate?

    private var previewLayer: AVCaptureVideoPreviewLayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        addTapToFocusGesture()
    }

    private func setupCamera() {
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: camera) else { return }

        captureSession.beginConfiguration()
        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }

        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
        self.previewLayer = previewLayer

        captureSession.commitConfiguration()
        captureSession.startRunning()
    }

    private func addTapToFocusGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleFocusTap(_:)))
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func handleFocusTap(_ gesture: UITapGestureRecognizer) {
        let touchPoint = gesture.location(in: view)
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return }

        let convertedPoint = previewLayer?.captureDevicePointConverted(fromLayerPoint: touchPoint) ?? CGPoint.zero

        do {
            try device.lockForConfiguration()
            if device.isFocusPointOfInterestSupported {
                device.focusPointOfInterest = convertedPoint
                device.focusMode = .autoFocus
            }
            device.unlockForConfiguration()
        } catch {
            print("Focus failed: \(error)")
        }

        delegate?.didTapToFocus(at: touchPoint)
    }
}
