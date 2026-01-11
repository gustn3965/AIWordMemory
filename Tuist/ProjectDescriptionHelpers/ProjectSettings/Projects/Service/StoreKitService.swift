//
//  StoreKitService.swift
//  ProjectDescriptionHelpers
//
//  Created by 박현수 on 1/14/25.
//

import Foundation

// MARK: - AI service
extension WMTarget {
    public static let storeKitServiceProjectName: String = "StoreKitService"
    
    public static func storeKitService() -> WMTarget {
        let targetName = "StoreKitService"
        return .templateDynamicFrameworkTarget(name: targetName,
                                              projectName: Self.storeKitServiceProjectName,
                                              infoPlist: defaultInfoPlist,
                                              sources: [.path("Implementation/Sources/**")],
                                              resources: [.path("Implementation/Resources/**")],
                                              settings: .appTalkDynamicFramework(targetName),
                                              dependencies: [
                                              ],
                                              scripts: [])
    }
}
