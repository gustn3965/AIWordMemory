//
//  ServiceFramework.swift
//  AIGPTManifests
//
//  Created by 박현수 on 12/22/24.
//

import Foundation

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.makeWM(
    .wmProject(name: WMTarget.aiServiceProjectName,
               targets: [
                .aiInterfaceService(),
                .aiImplementation(),
                .aiImplementationUnitTest()
               ],
               schemes: [
                .scheme(projectName: WMTarget.aiServiceProjectName,
                        configuration: .mockDebug,
                        buildTargets: [.aiImplementation()],
                        testTargets: [.aiImplementationUnitTest()])
               ])
)
