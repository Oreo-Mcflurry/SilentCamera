//
//  CameraViewModel.swift
//  Camera
//
//  Created by A_Mcflurry on 2/1/25.
//

import Foundation
import Combine
import UIKit

import Entities
import Extension
import DesignSystem

final class CameraViewModel: ObservableObject {
    
    // MARK: - Get CameraViewController Actions
    private var switchCamera: ((Bool) -> Void)?
    private var capturePhoto: (() -> Future<UIImage?, Never>)?
    private var switchFlash: ((Bool) -> Void)?
    private var switchGrid: ((Bool) -> Void)?
    private var brightness: ((Float) -> Void)?
    private var updateRatio: (() -> Void)?
    
    // MARK: - Combine
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Properties
    @Published var isBackCamera = true
    @Published var isFlashOn = false
    @Published var isGridOn = false
    @Published var brightnessValue: Float = 1
    @Published var cameraRatio: CameraRatio = ._4x3
    @Published var zoomScale: CGFloat = 1
    
    var cameraRatioImage: UIImage {
        switch cameraRatio {
        case ._4x3:
            return DesignSystemImage.btn_4x3
        case ._1x1:
            return DesignSystemImage.btn_1x1
        case ._16x9:
            return DesignSystemImage.btn_16x9
            
        }
    }
}

// MARK: - CameraViewController Actions
extension CameraViewModel {
    func cameraToggle() {
        isBackCamera.toggle()
        switchCamera?(isBackCamera)
    }
    
    func capture() {
        capturePhoto?()
            .compactMap { $0 }
            .sink { image in
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            }.store(in: &cancellables)
    }
    
    func flashToggle() {
        isFlashOn.toggle()
        switchFlash?(isFlashOn)
    }
    
    func gridToggle() {
        isGridOn.toggle()
        switchGrid?(isGridOn)
    }
    
    func cameraRatioToggle() {
        switch cameraRatio {
        case ._4x3:
            cameraRatio = ._1x1
        case ._1x1:
            cameraRatio = ._16x9
        case ._16x9:
            cameraRatio = ._4x3
        }
        updateRatio?()
    }
}

// MARK: - Configure Function
extension CameraViewModel {
    func configureActions(
        switchFlash: @escaping (Bool) -> Void,
        switchGrid: @escaping (Bool) -> Void,
        switchCamera: @escaping (Bool) -> Void,
        capturePhoto: @escaping () -> Future<UIImage?, Never>,
        brightness: @escaping (Float) -> Void,
        updateRatio: @escaping (() -> Void),
        zoomScaleSubject: PassthroughSubject<CGFloat, Never>
    ) {
        self.switchFlash = switchFlash
        self.switchGrid = switchGrid
        self.switchCamera = switchCamera
        self.capturePhoto = capturePhoto
        self.brightness = brightness
        self.updateRatio = updateRatio
        
        zoomScaleSubject
            .sink(with: self) { owner, value in
                owner.zoomScale = value
            }.store(in: &cancellables)
    }
}
