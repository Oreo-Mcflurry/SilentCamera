//
//  Project.swift
//  AppManifests
//
//  Created by A_Mcflurry on 1/31/25.
//

import ProjectDescription
import ProjectDescriptionHelpers
//
//private let fonts = [
//  "Pretendard-Light.otf",
//  "Pretendard-ExtraLight.otf",
//  "Pretendard-Thin.otf",
//  "Pretendard-Bold.otf",
//  "Pretendard-SemiBold.otf",
//  "Pretendard-Medium.otf",
//  "Pretendard-Black.otf",
//  "Pretendard-Regular.otf",
//  "Pretendard-ExtraBold.otf",
//]
//
//private let infoPlist: [String: Plist.Value] = [
//  "Fonts provided by application": .array(fonts.map { .string($0) })
//]

let project = Project.dynamicResourceFramework(
  name: Modules.Presentation.DesignSystem.rawValue,
//  infoPlist: .extendingDefault(with: infoPlist),
  dependencies: [
    .utility(target: .Extension),
  ]
)
