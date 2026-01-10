//
//  WMScheme.swift
//  ProjectDescriptionHelpers
//
//  Created by vapor on 10/13/24.
//

import Foundation

public struct WMScheme {
    var projectName: String
    var configuration: WMConfiguration
    var buildTargets: [WMTarget]
    var testTargets: [WMTarget]
    
    public static func scheme(projectName: String,
                              configuration: WMConfiguration,
                              buildTargets: [WMTarget],
                              testTargets: [WMTarget]) -> WMScheme {
        WMScheme(projectName: projectName,
                 configuration: configuration,
                 buildTargets: buildTargets,
                 testTargets: testTargets)
    }
}
