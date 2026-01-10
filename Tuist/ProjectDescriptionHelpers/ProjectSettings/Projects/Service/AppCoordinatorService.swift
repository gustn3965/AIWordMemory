//
//  AppCoordinatorService.swift
//  ProjectDescriptionHelpers
//
//  Created by 박현수 on 1/10/25.
//

import Foundation

// MARK: - AI service
extension WMTarget {
    public static let appCoordinatorServiceProjectName: String = "AppCoordinatorService"
    
    public static func appCoordinatorService() -> WMTarget {
        let targetName = "AppCoordinatorService"
        return .templateStaticFrameworkTarget(name: targetName,
                                              projectName: Self.appCoordinatorServiceProjectName,
                                              infoPlist: defaultInfoPlist,
                                              sources: [.path("Implementation/Sources/**")],
                                              resources: [.path("Implementation/Resources/**")],
                                              settings: .appTalkDynamicFramework(targetName),
                                              dependencies: [
                                              ],
                                              scripts: [])
    }
}
