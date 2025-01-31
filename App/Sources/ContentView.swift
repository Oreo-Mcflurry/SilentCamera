//
//  ContentView.swift
//  ContentView
//
//  Created by A_Mcflurry on 1/31/25.
//

import SwiftUI
import Router
import Coordinator

struct ContentView: View {
    @StateObject private var router = Router()
    
    var body: some View {
        NavigationStack(path: $router.path) {
            Button {
                router.push(to: .cameraView)
            } label: {
                Text("Test")
            }
            .navigationDestination(for: Route.self) {
                return Coordinator.view(for: $0)
            }
        }
    }
}
