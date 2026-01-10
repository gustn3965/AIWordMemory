//
//  FeatureProject.swift
//  AIGPTManifests
//
//  Created by 박현수 on 12/22/24.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.makeWM(
    .wmProject(name: WMTarget.searchFeatureProjectName,
               targets: [
                .searchFeature(),
                .searchUnitTest(),
                .searchSampleApp(),
               ],
               schemes: [
                   .scheme(projectName: WMTarget.searchFeatureProjectName,
                           configuration: .mockDebug,
                           buildTargets: [.searchSampleApp()],
                           testTargets: [.searchUnitTest()])
               ]
              )
)
