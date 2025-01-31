//
//  AppContants.swift
//  AppManifests
//
//  Created by A_Mcflurry on 1/31/25.
//

import ProjectDescription

public enum AppConstants {
  public static let appName: String = "Silent Camera"
  public static let organizationName: String = "com.yoo"
  public static let bundleId: String = "com.yoo.SilentCamera"
  public static let version: Plist.Value = "1.0.0"
  public static let build: Plist.Value = "1"
  public static let destinations: Set<Destination> = .iOS
  public static let deploymentTargets: DeploymentTargets = .iOS("16.0")
}
