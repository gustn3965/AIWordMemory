//
//  AppEntity.swift
//  AIServiceManifests
//
//  Created by 박현수 on 12/29/24.
//

import Foundation

extension WMTarget {
    public static let appEntityProjectName: String = "AppEntity"
    
    public static func appEntity() -> WMTarget {
        let targetName = "AppEntity"
        return .templateStaticFrameworkTarget(name: targetName,
                                              projectName: Self.appEntityProjectName,
                                              infoPlist: defaultInfoPlist,
                                              sources: [.path("Sources/**")],
                                              resources: [.path("Resources/**")],
                                              settings: .appTalkDynamicFramework(targetName),
                                              dependencies: [],
                                              scripts: [])
    }
}
