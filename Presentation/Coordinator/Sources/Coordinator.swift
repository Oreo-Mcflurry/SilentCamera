//
//  Coordinator.swift
//  Coordinator
//
//  Created by A_Mcflurry on 1/31/25.
//

import SwiftUICore
import Router

public struct Coordinator {
    @ViewBuilder
    public static func view(for route: Route) -> some View {
        switch route {
        case .cameraView:
            Text("cameraView")
        }
    }
}

