//
//  UserDefaultsManger.swift
//  Services
//
//  Created by A_Mcflurry on 2/4/25.
//

import Foundation

public protocol UserDefaultsMangerProtocol: AnyObject {
    subscript(_ key: UserDefaultsManger.UserDefaultsBoolKey) -> Bool { get set }
}

final public class UserDefaultsManger: UserDefaultsMangerProtocol {
    public enum UserDefaultsBoolKey: String {
        case isOnboardingCompleted
    }
    
    public subscript(_ key: UserDefaultsBoolKey) -> Bool {
        get {
            return UserDefaults.standard.bool(forKey: key.rawValue)
        } set {
            UserDefaults.standard.set(newValue, forKey: key.rawValue)
        }
    }
}
