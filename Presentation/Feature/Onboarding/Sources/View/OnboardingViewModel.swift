//
//  OnboardingViewModel.swift
//  Onboarding
//
//  Created by A_Mcflurry on 2/4/25.
//

import Foundation
import UseCases

final class OnboardingViewModel: ObservableObject {
    private let useCases: OnboardingViewUseCases
    
    init(useCases: OnboardingViewUseCases) {
        self.useCases = useCases
    }
}
