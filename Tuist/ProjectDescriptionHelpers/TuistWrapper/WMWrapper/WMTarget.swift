//
//  WMTarget.swift
//  ProjectDescriptionHelpers
//
//  Created by vapor on 10/13/24.
//

import Foundation

public struct WMTarget {
    
    enum Product {
        case app
        case appUnitTest
        case appHelper
        case appShare
        case dynamicFramework
        case staticFramework
    }
    
    enum Destinations {
        case iOS
    }
    
    enum DeployTargets {
        case iOS(String)
    }
    
    
//    var target: WMCurrentTarget
    var name: String
    var projectName: String
    var destinations: Destinations
    var product: Product
    var bundleId: String = "${PRODUCT_BUNDLE_IDENTIFIER}"   // Settings에서
    var infoPlist: [String: String]
    var depolymentTargets: DeployTargets
    var sources: [WMSourceFileList]
    var resources: [WMResourceFileList]
    var headers: [WMHeaders]
    var additionalFiles: [WMPath]
    var settings: WMSettings
    var dependencies: [WMTargetDependencies]
    var scripts: [WMTargetScript]
    
    
    
    public static func templateAppTarget(name: String,
                                         projectName: String,
                                         infoPlist: [String: String],
                                         sources: [WMSourceFileList] = [],
                                         resources: [WMResourceFileList] = [],
                                         headers: [WMHeaders] = [],
                                         settings: WMSettings,
                                         additionalFiles: [WMPath] = [],
                                         dependencies: [WMTargetDependencies],
                                         scripts: [WMTargetScript]) -> WMTarget {
        WMTarget(name: name,
                 projectName: projectName,
                 destinations: .iOS,
                 product: .app,
                 infoPlist: infoPlist,
                 depolymentTargets: .iOS(deploymentTargetiOS),
                 sources: sources,
                 resources: resources,
                 headers: headers,
                 additionalFiles: additionalFiles,
                 settings: settings,
                 dependencies: dependencies,
                 scripts: scripts)
    }
    
    public static func templateUnitTest(name: String,
                                        projectName: String,
                                        infoPlist: [String: String],
                                        sources: [WMSourceFileList] = [],
                                        resources: [WMResourceFileList] = [],
                                        headers: [WMHeaders] = [],
                                        settings: WMSettings,
                                        additionalFiles: [WMPath] = [],
                                        dependencies: [WMTargetDependencies],
                                        scripts: [WMTargetScript])-> WMTarget {
        WMTarget(name: name,
                 projectName: projectName,
                 destinations: .iOS,
                 product: .appUnitTest,
                 infoPlist: infoPlist,
                 depolymentTargets: .iOS(deploymentTargetiOS),
                 sources: sources,
                 resources: resources,
                 headers: headers,
                 additionalFiles: additionalFiles,
                 settings: settings,
                 dependencies: dependencies,
                 scripts: scripts)
    }
    
    public static func templateDynamicFrameworkTarget(name: String,
                                                      projectName: String,
                                                      infoPlist: [String: String],
                                                      sources: [WMSourceFileList] = [],
                                                      resources: [WMResourceFileList] = [],
                                                      headers: [WMHeaders] = [],
                                                      settings: WMSettings,
                                                      additionalFiles: [WMPath] = [],
                                                      dependencies: [WMTargetDependencies],
                                                      scripts: [WMTargetScript])-> WMTarget {
        WMTarget(name: name,
                 projectName: projectName,
                 destinations: .iOS,
                 product: .dynamicFramework,
                 infoPlist: infoPlist,
                 depolymentTargets: .iOS(deploymentTargetiOS),
                 sources: sources,
                 resources: resources,
                 headers: headers,
                 additionalFiles: additionalFiles,
                 settings: settings,
                 dependencies: dependencies,
                 scripts: scripts)
    }
    
    public static func templateStaticFrameworkTarget(name: String,
                                                     projectName: String,
                                                     infoPlist: [String: String],
                                                     sources: [WMSourceFileList] = [],
                                                     resources: [WMResourceFileList] = [],
                                                     headers: [WMHeaders] = [],
                                                     settings: WMSettings,
                                                     additionalFiles: [WMPath] = [],
                                                     dependencies: [WMTargetDependencies],
                                                     scripts: [WMTargetScript])-> WMTarget {
        WMTarget(name: name,
                 projectName: projectName,
                 destinations: .iOS,
                 product: .staticFramework,
                 infoPlist: infoPlist,
                 depolymentTargets: .iOS(deploymentTargetiOS),
                 sources: sources,
                 resources: resources,
                 headers: headers,
                 additionalFiles: additionalFiles,
                 settings: settings,
                 dependencies: dependencies,
                 scripts: scripts)
    }
    
}
