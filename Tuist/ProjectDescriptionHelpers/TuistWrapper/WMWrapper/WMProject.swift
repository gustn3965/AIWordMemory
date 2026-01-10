//
//  WMProject.swift
//  ProjectDescriptionHelpers
//
//  Created by vapor on 10/13/24.
//

import Foundation


public struct WMProject {
    var name: String
    var settings: WMSettings
    var targets: [WMTarget]
    var schemes: [WMScheme]
    
    public static func wmProject(name: String, targets: [WMTarget], schemes: [WMScheme]) -> WMProject {
        WMProject(name: name, settings: .talkBaseProject(), targets: targets, schemes: schemes)
    }
}
