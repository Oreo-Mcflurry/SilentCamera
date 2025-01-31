//
//  Project+app.swift
//  AppManifests
//
//  Created by A_Mcflurry on 1/31/25.
//

import ProjectDescription

extension Project {
  public static func app(
    dependencies: [TargetDependency] = [],
    packages: [Package] = []
  ) -> Project {
    let name = AppConstants.appName
    let target = Target.target(
      name: AppConstants.appName,
      destinations: AppConstants.destinations,
      product: .app,
      bundleId: AppConstants.bundleId,
      deploymentTargets: AppConstants.deploymentTargets,
      infoPlist: .extendingDefault(with: [
          "UILaunchScreen": "LaunchScreen",
          "NSCameraUsageDescription": "The app requires access to the camera to capture photos.",
          "NSPhotoLibraryUsageDescription": "The app needs access to your photo library to display and save photos.",
          "NSPhotoLibraryAddUsageDescription": "The app requires permission to add photos to your library."
      ]),
      sources: ["Sources/**"],
      resources: ["Resources/**"],
      dependencies: dependencies,
      settings: .settings(
        configurations: [
            .debug(name: "Debug", settings: [
                "CODE_SIGN_STYLE": "Automatic",
                "DEVELOPMENT_TEAM": "\(PrivateKey.teamID)",
                "CODE_SIGN_IDENTITY": "Apple Development"
            ]),
            .release(name: "Release", settings: [
                "CODE_SIGN_STYLE": "Automatic",
                "DEVELOPMENT_TEAM": "\(PrivateKey.teamID)",
                "CODE_SIGN_IDENTITY": "Apple Development"
            ])
        ]
    ),
      environmentVariables: [:],
      additionalFiles: []
    )
    
    return Project(
      name: name,
      organizationName: AppConstants.organizationName,
      options: .options(
        automaticSchemesOptions: .disabled,
        developmentRegion: "kor"
      ),
      packages: packages,
      settings: .settings(),
//          .settings(configurations: [
//        .configuration(environment: .dev),
//        .configuration(environment: .prod),
//      ]),
      targets: [target],
      schemes: [
        .makeScheme(),
//        .makeScheme(environment: .dev),
//        .makeScheme(environment: .prod),
      ]
    )
  }
}
