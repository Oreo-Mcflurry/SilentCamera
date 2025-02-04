//
//  Project.swift
//  AppManifests
//
//  Created by A_Mcflurry on 2/4/25.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.dynamicFramework(
    name: Modules.Domain.Services.rawValue,
    dependencies: [
        .domain(target: .Entities)
    ]
)
