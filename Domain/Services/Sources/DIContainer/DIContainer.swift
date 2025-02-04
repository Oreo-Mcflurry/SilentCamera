//
//  DIContainer.swift
//  Services
//
//  Created by A_Mcflurry on 2/4/25.
//

import Foundation

public class DIContainer {
    public static let shared = DIContainer()
    private init() {
        userDefaultsManger = UserDefaultsManger()
    }
    
    public let userDefaultsManger: UserDefaultsMangerProtocol
}
