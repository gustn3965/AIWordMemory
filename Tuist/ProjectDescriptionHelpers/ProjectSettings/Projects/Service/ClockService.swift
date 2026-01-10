//
//  ClockService.swift
//  ProjectDescriptionHelpers
//
//  Created by 박현수 on 1/7/25.
//

import Foundation

// MARK: - AI service
extension WMTarget {
    public static let clockServiceProjectName: String = "ClockService"
    
    public static func clockImplementationService() -> WMTarget {
        let targetName = "ClockImplementation"
        return .templateStaticFrameworkTarget(name: targetName,
                                              projectName: Self.clockServiceProjectName,
                                              infoPlist: defaultInfoPlist,
                                              sources: [.path("Implementation/Sources/**")],
                                              resources: [.path("Implementation/Resources/**")],
                                              settings: .appTalkDynamicFramework(targetName),
                                              dependencies: [
                                                .spm(name: "Kronos")
                                              ],
                                              scripts: [])
    }
}
