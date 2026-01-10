//
//  FeatureProject.swift
//  AIGPTManifests
//
//  Created by 박현수 on 12/22/24.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.makeWM(
    .wmProject(name: WMTarget.settingsFeatureProjectName,
               targets: [
                .settingsFeature(),
                .settingsUnitTest(),
                .settingsSampleApp(),
               ],
               schemes: [
                   .scheme(projectName: WMTarget.settingsFeatureProjectName,
                           configuration: .mockDebug,
                           buildTargets: [.settingsSampleApp()],
                           testTargets: [.settingsUnitTest()])
               ]
               )
)
