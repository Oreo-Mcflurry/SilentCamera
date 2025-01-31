//
//  Project.swift
//  AppManifests
//
//  Created by A_Mcflurry on 1/31/25.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.dynamicFramework(
    name: Modules.Presentation.Coordinator.rawValue,
    dependencies: [
        .domain(target: .UseCases),
        .presentation(target: .Router),
        .presentation(target: .Camera)
    ]
)
