//
//  OnboardingViewUseCases.swift
//  UseCases
//
//  Created by A_Mcflurry on 2/4/25.
//

import Foundation
import Services

public protocol OnboardingViewUseCases {
    func setOnboardingCompleted(_ value: Bool)
}

final class OnboardingViewUseCasesImpl: OnboardingViewUseCases {
    init(userDefaultsManger: UserDefaultsMangerProtocol) {
        self.userDefaultsManger = userDefaultsManger
    }
    
    private let userDefaultsManger: UserDefaultsMangerProtocol
    
    func setOnboardingCompleted(_ value: Bool) {
        userDefaultsManger[.isOnboardingCompleted] = value
    }
}
