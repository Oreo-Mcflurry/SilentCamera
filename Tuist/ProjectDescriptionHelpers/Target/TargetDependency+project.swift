//
//  TargetDependency+project.swift
//  AppManifests
//
//  Created by A_Mcflurry on 1/31/25.
//

import ProjectDescription

public extension TargetDependency {
  static func data(target: Modules.Data) -> TargetDependency {
    .project(
      target: target.targetName,
      path: .relativeToRoot(target.path)
    )
  }
  
  static func domain(target: Modules.Domain) -> TargetDependency {
    .project(
      target: target.targetName,
      path: .relativeToRoot(target.path)
    )
  }
  
  static func utility(target: Modules.Utility) -> TargetDependency {
    .project(
      target: target.targetName,
      path: .relativeToRoot(target.path)
    )
  }
  
  static func presentation(target: Modules.Presentation) -> TargetDependency {
    .project(
      target: target.targetName,
      path: .relativeToRoot(target.path)
    )
  }
}
