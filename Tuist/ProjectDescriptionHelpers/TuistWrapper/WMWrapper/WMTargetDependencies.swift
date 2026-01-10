//
//  WMTargetDependencies.swift
//  ProjectDescriptionHelpers
//
//  Created by vapor on 10/13/24.
//

import Foundation

public enum WMTargetDependencies {
    case target(name: String)
    case xcframework(path: WMPath)
    case framework(path: WMPath)
    case sdk(name: String, type: WMSDKType)
    case library(path: WMPath, publicHeaders: WMPath)
    case spm(name: String)
    case project(target: String)
    
    
    
    
    case currentTarget(target: WMTarget)
    
//        .project(target: <#T##String#>, path: <#T##Path#>, status: <#T##LinkingStatus#>, condition: <#T##PlatformCondition?#>)
}

public enum WMSDKType {
    case library
    case swiftLibrary
    case framework
}
