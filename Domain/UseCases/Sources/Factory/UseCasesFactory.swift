//
//  UseCasesFactory.swift
//  UseCases
//
//  Created by A_Mcflurry on 2/4/25.
//

import Foundation
import Services

public final class UserCasesFactory {
    private static let diContainer = DIContainer.shared
    
    public static func createOnboardingViewUseCase() -> OnboardingViewUseCases {
        return OnboardingViewUseCasesImpl(userDefaultsManger: diContainer.userDefaultsManger)
    }
    
    public static func createInitialViewUseCase() -> InitalViewUseCasesProtocol {
        return InitalViewUseCasesImpl(userDefaultsManger: diContainer.userDefaultsManger)
    }
}
