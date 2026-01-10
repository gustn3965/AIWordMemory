//
//  FeatureProject.swift
//  AIGPTManifests
//
//  Created by 박현수 on 12/22/24.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.makeWM(
    .wmProject(name: WMTarget.mainHomeFeatureProjectName,
               targets: [
                .mainHomeFeature(),
                .mainHomeUnitTest(),
                .mainHomeSampleApp(),
               ],
               schemes: [
                   .scheme(projectName: WMTarget.mainHomeFeatureProjectName,
                           configuration: .mockDebug,
                           buildTargets: [.mainHomeSampleApp()],
                           testTargets: [.mainHomeUnitTest()])
               ]
              )
)
