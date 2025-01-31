//
//  Schme+makeScheme.swift
//  AppManifests
//
//  Created by A_Mcflurry on 1/31/25.
//

import ProjectDescription

extension Scheme {
  public static func makeScheme(/*environment: AppEnvironment*/) -> Scheme {
    return .scheme(
      name: "\(AppConstants.appName)"/*-\(environment.rawValue)*/,
      buildAction: .buildAction(targets: ["\(AppConstants.appName)"]),
      runAction: .runAction(configuration: "Debug"),// environment.configurationName),
      archiveAction: .archiveAction(configuration: "Release"), //environment.configurationName),
      profileAction: .profileAction(configuration: "Release"), //environment.configurationName),
      analyzeAction: .analyzeAction(configuration: "Debug") //environment.configurationName)
    )
  }
}
