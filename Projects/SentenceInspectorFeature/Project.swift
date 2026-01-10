//
//  FeatureProject.swift
//  AIGPTManifests
//
//  Created by 박현수 on 12/22/24.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.makeWM(
    .wmProject(name: WMTarget.sentenceInspectorFeatureProjectName,
               targets: [
                .sentenceInspectorFeature(),
                .sentenceInspectorUnitTest(),
                .sentenceInspectorSampleApp(),
               ],
               schemes: [
                   .scheme(projectName: WMTarget.sentenceInspectorFeatureProjectName,
                           configuration: .mockDebug,
                           buildTargets: [.sentenceInspectorSampleApp()],
                           testTargets: [.sentenceInspectorUnitTest()])
               ]
              )
)
