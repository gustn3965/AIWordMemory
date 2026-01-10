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
    .wmProject(name: WMTarget.dbServiceProjectName,
               targets: [
                .dbInterfaceService(),
                .dbImplementation(),
                .dbImplementationUnitTest()
               ],
               schemes: [
                   .scheme(projectName: WMTarget.dbServiceProjectName,
                           configuration: .mockDebug,
                           buildTargets: [.dbImplementation()],
                           testTargets: [.dbImplementationUnitTest()])
               ]
              )
)
