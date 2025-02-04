//
//  InitalViewUseCases.swift
//  UseCases
//
//  Created by A_Mcflurry on 2/4/25.
//

import Foundation
import Services

public protocol InitalViewUseCasesProtocol {
    func isOnboardingCompleted() -> Bool
}

final class InitalViewUseCasesImpl: InitalViewUseCasesProtocol {
    init(userDefaultsManger: UserDefaultsMangerProtocol) {
        self.userDefaultsManger = userDefaultsManger
    }
    
    private let userDefaultsManger: UserDefaultsMangerProtocol
    
    func isOnboardingCompleted() -> Bool {
        return userDefaultsManger[.isOnboardingCompleted]
    }
}
