//
//  DBService.swift
//  ProjectDescriptionHelpers
//
//  Created by 박현수 on 12/24/24.
//

import Foundation

// MARK: - DB service
extension WMTarget {
    public static let dbServiceProjectName: String = "DBService"
    
    public static func dbInterfaceService() -> WMTarget {
        let targetName = "DBInterface"
        return .templateDynamicFrameworkTarget(name: targetName,
                                              projectName: Self.dbServiceProjectName,
                                              infoPlist: defaultInfoPlist,
                                              sources: [.path("Interface/Sources/**")],
                                              resources: [.path("Interface/Resources/**")],
                                              settings: .appTalkDynamicFramework(targetName),
                                              dependencies: [
                                                .currentTarget(target: .appEntity()),
                                                .currentTarget(target: .accountInterfaceService()),
                                              ],
                                              scripts: [])
    }
    public static func dbImplementation() -> WMTarget {
        let targetName = "DBImplementation"
        return templateDynamicFrameworkTarget(name: targetName,
                                            projectName: Self.dbServiceProjectName,
                                            infoPlist: defaultInfoPlist,
                                            sources: [.path("Implementation/Sources/**")],
                                            resources: [.path("Implementation/Resources/**")],
                                            settings: .appTalkDynamicFramework(targetName),
                                            dependencies: [
                                                .currentTarget(target: Self.dbInterfaceService()),
                                                .currentTarget(target: .appEntity()),
                                                .currentTarget(target: .accountInterfaceService()),
                                            ],
                                            scripts: [])
    }
    
    public static func dbImplementationUnitTest() -> WMTarget {
        let targetName = "DBImplementationUnitTest"
        return .templateUnitTest(name: targetName,
                                 projectName: Self.dbServiceProjectName,
                                 infoPlist: defaultInfoPlist,
                                 sources: [.path("Implementation/Tests/**")],
                                 settings: .appTalkUnitTestTarget(targetName),
                                 dependencies: [.currentTarget(target: Self.dbImplementation())],
                                 scripts: [])
    }
}
