//
//  Button+.swift
//  Extension
//
//  Created by A_Mcflurry on 2/2/25.
//

import SwiftUI

public extension View {
    func makeButton(action: @escaping () -> Void) -> some View {
        self.modifier(MakeButtonModifier(action: action))
    }
}

fileprivate struct MakeButtonModifier: ViewModifier {
    let action: () -> Void

    func body(content: Content) -> some View {
        Button(action: action) {
            content
        }
    }
}
