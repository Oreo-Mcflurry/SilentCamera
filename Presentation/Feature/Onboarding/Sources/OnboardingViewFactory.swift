//
//  OnboardingViewFactory.swift
//  Onboarding
//
//  Created by A_Mcflurry on 2/4/25.
//

import SwiftUI
import UseCases

public final class OnboardingViewFactory {
    @ViewBuilder
    public static func createOnboardingView(_ useCase: OnboardingViewUseCases) -> some View {
        let viewModel = OnboardingViewModel(useCases: useCase)
        OnboardingView(viewModel: viewModel)
    }
}
