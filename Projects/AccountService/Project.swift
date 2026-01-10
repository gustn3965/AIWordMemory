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
    .wmProject(
        name: WMTarget.accountServiceProjectName,
        targets: [
            .accountInterfaceService(),
            .accountImplementation(),
            .accountImplementationUnitTest()
        ],
        schemes: [
            .scheme(
                projectName: WMTarget.accountServiceProjectName,
                configuration: .mockDebug,
                buildTargets: [.accountImplementation()],
                testTargets: [.accountImplementationUnitTest()]
            )
        ]
    )
)
