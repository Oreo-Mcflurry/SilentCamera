//
//  CameraViewFactory.swift
//  Camera
//
//  Created by A_Mcflurry on 1/31/25.
//

import SwiftUI
import UseCases

public final class CameraViewFactory {
    @ViewBuilder
    public static func createCameraView() -> some View {
        CameraView()
    }
}
