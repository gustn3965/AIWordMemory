//
//  FeatureProject.swift
//  AIGPTManifests
//
//  Created by 박현수 on 12/22/24.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.makeWM(
    .wmProject(name: WMTarget.recommendFeatureProjectName,
               targets: [
                .recommendFeature(),
                .recommendUnitTest(),
                .recommendSampleApp(),
               ],
               schemes: [
                   .scheme(projectName: WMTarget.recommendFeatureProjectName,
                           configuration: .mockDebug,
                           buildTargets: [.recommendSampleApp()],
                           testTargets: [.recommendUnitTest()])
               ]
              )
)
