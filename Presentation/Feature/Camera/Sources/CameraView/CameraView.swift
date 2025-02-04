//
//  CameraView.swift
//  Camera
//
//  Created by A_Mcflurry on 2/1/25.
//

import SwiftUI
import Extension
import DesignSystem

struct CameraView: View {
    @StateObject private var viewModel = CameraViewModel()
    
    var body: some View {
        ZStack {
            SessionView
            SessionOverlayView
        }
        .padding(.top, 20)
        .background(DesignSystemColor.background343A41)
        .toolbar { TopToolbarView }
        .navigationBarBackButtonHidden()
    }
}

// MARK: - Views
extension CameraView {
    private enum Constants {
        static let cameraButtonSize: CGSize = CGSize(width: 90, height: 90)
        static let cameraButtonStrokeWidth: CGFloat = 1
        static let cameraButtonColor: Color = .white
        static let cameraButtonBorderColor: Color = .black.opacity(0.8)
    }
    
    @ViewBuilder
    private var SessionOverlayView: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.clear)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .aspectRatio(3/4, contentMode: .fit)
                .layoutPriority(1)
            
            BottomView
        }
    }
    
    @ToolbarContentBuilder
    private var TopToolbarView: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            HStack {
                Image(systemName: viewModel.isFlashOn ? "bolt.fill" : "bolt.slash")
                    .resizable()
                    .frame(width: 22, height: 22)
                    .foregroundStyle(viewModel.isFlashOn ? .yellow : .white)
                    .makeButton {
                        viewModel.flashToggle()
                    }
                
                Image(systemName: "squareshape.split.3x3")
                    .resizable()
                    .frame(width: 22, height: 22)
                    .foregroundStyle(viewModel.isGridOn ? .yellow : .white)
                    .makeButton {
                        viewModel.gridToggle()
                    }
                
                Image(uiImage: viewModel.cameraRatio == ._1x1 ? DesignSystemImage.btn_1x1 : DesignSystemImage.btn_4x3)
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 22, height: 22)
                    .foregroundStyle(.white)
                    .makeButton {
                        viewModel.cameraRatioToggle()
                    }
            }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            Image(systemName: "arrow.trianglehead.2.counterclockwise.rotate.90")
                .foregroundStyle(.white)
                .makeButton {
                    viewModel.cameraToggle()
                }
        }
    }
    
    @ViewBuilder
    private var SessionView: some View {
        VStack(spacing: 0) {
            CameraSessionView(viewModel: viewModel)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .aspectRatio(viewModel.cameraRatio.ratio, contentMode: .fit)
                .layoutPriority(1)
            
            Spacer(minLength: 0)
        }
    }
    
    @ViewBuilder
    private var BottomView: some View {
        HStack {
            CaptureButtonView
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .layoutPriority(0)
    }
    
    @ViewBuilder
    private var CaptureButtonView: some View {
        Image(uiImage: DesignSystemImage.btn_capture)
            .resizable()
            .frame(width: Constants.cameraButtonSize.width, height: Constants.cameraButtonSize.height)
            .overlay { Circle().stroke(Constants.cameraButtonBorderColor, lineWidth: Constants.cameraButtonStrokeWidth) }
            .makeButton {
                viewModel.capture()
            }
    }
}
