//
//  AccountSerivce.swift
//  ProjectDescriptionHelpers
//
//  Created by 박현수 on 1/7/25.
//

import Foundation

// MARK: - AI service
extension WMTarget {
    public static let accountServiceProjectName: String = "AccountService"
    
    public static func accountInterfaceService() -> WMTarget {
        let targetName = "AccountInterface"
        return .templateDynamicFrameworkTarget(name: targetName,
                                              projectName: Self.accountServiceProjectName,
                                              infoPlist: defaultInfoPlist,
                                              sources: [.path("Interface/Sources/**")],
                                              resources: [.path("Interface/Resources/**")],
                                              settings: .appTalkDynamicFramework(targetName),
                                              dependencies: [
                                                .currentTarget(target: .appEntity()),
                                              ],
                                              scripts: [])
    }
    public static func accountImplementation() -> WMTarget {
        let targetName = "AccountImplementation"
        return .templateDynamicFrameworkTarget(name: targetName,
                                               projectName: Self.accountServiceProjectName,
                                               infoPlist: defaultInfoPlist,
                                               sources: [.path("Implementation/Sources/**")],
                                               resources: [.path("Implementation/Resources/**")],
                                               settings: .appTalkDynamicFramework(targetName),
                                               dependencies: [
                                                .currentTarget(target: Self.accountInterfaceService()),
                                                .currentTarget(target: .appEntity()),
                                               ],
                                               scripts: [])
    }
    
    
    public static func accountImplementationUnitTest() -> WMTarget {
        let targetName = "AccountImplementationUnitTest"
        return .templateUnitTest(name: targetName,
                                 projectName: Self.accountServiceProjectName,
                                 infoPlist: defaultInfoPlist,
                                 sources: [.path("Implementation/Tests/**")],
                                 settings: .appTalkUnitTestTarget(targetName),
                                 dependencies: [
                                    .currentTarget(target: Self.accountImplementation())
                                 ],
                                 scripts: [])
    }
}
