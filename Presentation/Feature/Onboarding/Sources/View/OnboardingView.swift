//
//  OnboardingVIew.swift
//  Onboarding
//
//  Created by A_Mcflurry on 2/4/25.
//

import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel: OnboardingViewModel
    
    init(viewModel: OnboardingViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        Text("123")
    }
}
