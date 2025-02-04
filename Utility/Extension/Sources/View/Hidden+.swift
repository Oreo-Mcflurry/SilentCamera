//
//  Hidden+.swift
//  Extension
//
//  Created by A_Mcflurry on 2/3/25.
//

import SwiftUI

public extension View {
    @ViewBuilder
    func hidden(of isHidden: Bool) -> some View {
        if !isHidden {
            self
        }
    }
}
