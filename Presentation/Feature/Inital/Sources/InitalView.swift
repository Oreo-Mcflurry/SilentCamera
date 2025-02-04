//
//  InitalView.swift
//  Inital
//
//  Created by A_Mcflurry on 2/4/25.
//

import SwiftUI
import Router
import Coordinator
import UseCases

public struct InitalView: View {
    @StateObject private var router = Router()
    private let useCases: InitalViewUseCasesProtocol
    
    public init(useCases: InitalViewUseCasesProtocol = UserCasesFactory.createInitialViewUseCase()) {
        self.useCases = useCases
    }
    
    public var body: some View {
        NavigationStack(path: $router.path) {
            Group {
                if useCases.isOnboardingCompleted() {
                    Coordinator.view(for: .cameraView)
                } else {
                    Coordinator.view(for: .onboardingView)
                }
            }
            .navigationDestination(for: Route.self) {
                return Coordinator.view(for: $0)
            }
        }
    }
}
