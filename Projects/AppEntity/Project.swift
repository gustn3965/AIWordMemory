//
//  Project.swift
//  AIServiceManifests
//
//  Created by 박현수 on 12/29/24.
//

import Foundation
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.makeWM(
    .wmProject(name: WMTarget.appEntityProjectName,
               targets: [
                .appEntity(),
               ],
               schemes: [])
)
