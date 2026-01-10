//
//  FeatureProject.swift
//  AIGPTManifests
//
//  Created by 박현수 on 12/22/24.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.makeWM(
    .wmProject(name: WMTarget.reviewFeatureProjectName,
               targets: [
                .reviewFeature(),
                .reviewUnitTest(),
                .reviewSampleApp(),
               ],
               schemes: [
                   .scheme(projectName: WMTarget.reviewFeatureProjectName,
                           configuration: .mockDebug,
                           buildTargets: [.reviewSampleApp()],
                           testTargets: [.reviewUnitTest()])
               ]
              )
)
