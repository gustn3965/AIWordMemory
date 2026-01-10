//
//  FeatureProject.swift
//  AIGPTManifests
//
//  Created by 박현수 on 12/22/24.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.makeWM(
    .wmProject(name: WMTarget.sampleFeatureProjectName,
               targets: [
                .sampleFeature(),
                .sampleUnitTest(),
                .sampleSampleApp(),
               ],
               schemes: [
                   .scheme(projectName: WMTarget.sampleFeatureProjectName,
                           configuration: .mockDebug,
                           buildTargets: [.sampleSampleApp()],
                           testTargets: [.sampleUnitTest()])
               ]
              )
)
