//
//  WMTargetScript.swift
//  ProjectDescriptionHelpers
//
//  Created by vapor on 10/13/24.
//

import Foundation


public struct WMTargetScript {
    var script: String
    var name: String
    var inputPaths: [WMPath]
    var inputFileListPaths: [WMPath]
    var outputPaths: [WMPath]
    var outputFileListPaths: [WMPath]
    var basedOnDependencyAnalysis: Bool
    var runForInstallBuildsOnly: Bool
    var isPreOrder: Bool
    
    public static func pre(script: String,
                           name: String,
                           basedOnDependencyAnalysis: Bool,
                           runForInstallBuildsOnly: Bool) -> WMTargetScript {
        WMTargetScript(script: script,
                         name: name,
                         inputPaths: [],
                         inputFileListPaths: [],
                         outputPaths: [],
                         outputFileListPaths: [],
                         basedOnDependencyAnalysis: basedOnDependencyAnalysis,
                         runForInstallBuildsOnly: runForInstallBuildsOnly,
                         isPreOrder: true)
    }
    
    public static func post(script: String,
                            name: String,
                            basedOnDependencyAnalysis: Bool,
                            runForInstallBuildsOnly: Bool) -> WMTargetScript {
        WMTargetScript(script: script,
                         name: name,
                         inputPaths: [],
                         inputFileListPaths: [],
                         outputPaths: [],
                         outputFileListPaths: [],
                         basedOnDependencyAnalysis: basedOnDependencyAnalysis,
                         runForInstallBuildsOnly: runForInstallBuildsOnly,
                         isPreOrder: false)
    }
}
