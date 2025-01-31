//
//  Router.swift
//  Router
//
//  Created by A_Mcflurry on 1/31/25.
//

import SwiftUI

public final class Router: ObservableObject {
    @Published public var path = NavigationPath()
    
    public init() { }
    
    public func push(to route: Route) {
        path.append(route)
    }
    
    public func pop() {
        path.removeLast()
    }
    
    public func popToRoot() {
        path.removeLast(path.count)
    }
}
