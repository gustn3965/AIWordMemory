//
//  UIFrameworkProject.swift
//  Packages
//
//  Created by 박현수 on 12/21/24.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.makeWM(
    .wmProject(name: WMTarget.wordMemoryProjectName,
               targets: [
                .wordMemoryApp(),
                .wordMemoryUnitTest(),
                
               ],
               schemes: WMConfiguration.allCases.map {
                   .scheme(projectName: WMTarget.wordMemoryProjectName,
                           configuration: $0,
                           buildTargets: [.wordMemoryApp()],
                           testTargets: [.wordMemoryUnitTest()])
               }
              )
)
