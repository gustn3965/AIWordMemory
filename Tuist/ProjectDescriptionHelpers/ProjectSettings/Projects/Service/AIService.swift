//
//  AIService.swift
//  ProjectDescriptionHelpers
//
//  Created by 박현수 on 12/24/24.
//

import Foundation
// MARK: - AI service
extension WMTarget {
    public static let aiServiceProjectName: String = "AIService"
    
    public static func aiInterfaceService() -> WMTarget {
        let targetName = "AIInterface"
        return .templateDynamicFrameworkTarget(name: targetName,
                                              projectName: Self.aiServiceProjectName,
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
    public static func aiImplementation() -> WMTarget {
        let targetName = "AIImplementation"
        return .templateDynamicFrameworkTarget(name: targetName,
                                               projectName: Self.aiServiceProjectName,
                                               infoPlist: defaultInfoPlist,
                                               sources: [.path("Implementation/Sources/**")],
                                               resources: [.path("Implementation/Resources/**")],
                                               settings: .appTalkDynamicFramework(targetName),
                                               dependencies: [
                                                .currentTarget(target: Self.aiInterfaceService()),
                                                .currentTarget(target: .appEntity()),
                                                .currentTarget(target: .accountInterfaceService()),
                                                .currentTarget(target: .clockImplementationService()),
                                               ],
                                               scripts: [])
    }
    
    
    public static func aiImplementationUnitTest() -> WMTarget {
        let targetName = "AIImplementationUnitTest"
        return .templateUnitTest(name: targetName,
                                 projectName: Self.aiServiceProjectName,
                                 infoPlist: defaultInfoPlist,
                                 sources: [.path("Implementation/Tests/**")],
                                 settings: .appTalkUnitTestTarget(targetName),
                                 dependencies: [
                                    .currentTarget(target: Self.aiImplementation())
                                 ],
                                 scripts: [])
    }
}
