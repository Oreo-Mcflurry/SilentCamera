//
//  CameraView.swift
//  Camera
//
//  Created by A_Mcflurry on 2/1/25.
//

import SwiftUI

struct CameraView: View {
    @StateObject private var viewModel = CameraViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            CameraSessionView(viewModel: viewModel)
            
        }
    }
}
