//
//  Project.swift
//  AppManifests
//
//  Created by A_Mcflurry on 1/31/25.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.staticLibrary(
    name: Modules.Presentation.Library.rawValue,
    dependencies: [
        .domain(target: .UseCases),
        .presentation(target: .DesignSystem),
        .presentation(target: .Router),
    ]
)
