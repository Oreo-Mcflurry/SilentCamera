//
//  Project.swift
//  AppManifests
//
//  Created by A_Mcflurry on 2/4/25.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.staticLibrary(
    name: Modules.Presentation.Inital.rawValue,
    dependencies: [
        .domain(target: .UseCases),
        .presentation(target: .Router),
        .presentation(target: .Coordinator),
        .utility(target: .Extension),
    ]
)
