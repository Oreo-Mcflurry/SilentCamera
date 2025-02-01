//
//  CameraViewModel.swift
//  Camera
//
//  Created by A_Mcflurry on 2/1/25.
//

import Foundation
import Combine
import UIKit
import Extension

final class CameraViewModel: ObservableObject {
    
    var switchCamera: ((Bool) -> Void)?
    var capturePhoto: (() -> Future<UIImage?, Never>)?
    var switchFlash: ((Bool) -> Void)?
    var switchGrid: ((Bool) -> Void)?
    var brightness: ((Float) -> Void)?
    private var cancellables = Set<AnyCancellable>()
    
    func switchCamera(isBack: Bool) {
        switchCamera?(isBack)
    }
    
    func capture() {
        capturePhoto?()
            .sink { image in
                
            }.store(in: &cancellables)
    }
    
    func switchFlash(isOn: Bool) {
        switchFlash?(isOn)
    }
}
