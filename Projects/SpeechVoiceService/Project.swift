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
    .wmProject(name: WMTarget.speechVoiceServiceProjectName,
               targets: [
                .speechVoiceInterfaceService(),
                .speechVoiceImplementation(),
                .speechVoiceImplementationUnitTest()
               ],
               schemes: [
                .scheme(projectName: WMTarget.speechVoiceServiceProjectName,
                        configuration: .mockDebug,
                        buildTargets: [.speechVoiceImplementation()],
                        testTargets: [.speechVoiceImplementationUnitTest()])
               ]
              )
)
