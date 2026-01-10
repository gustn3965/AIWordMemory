//
//  FeatureProject.swift
//  AIGPTManifests
//
//  Created by 박현수 on 12/22/24.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.makeWM(
    .wmProject(name: WMTarget.commonUIFeatureProjectName,
               targets: [
                .commonUIFeature(),
                .commonUISampleApp(),
               ],
               schemes: [
                   .scheme(projectName: WMTarget.commonUIFeatureProjectName,
                           configuration: .mockDebug,
                           buildTargets: [.commonUISampleApp()],
                           testTargets: [])
               ]
              )
)
