//
//  SpeachVoiceService.swift
//  ProjectDescriptionHelpers
//
//  Created by 박현수 on 1/2/25.
//

import Foundation

extension WMTarget {
    public static let speechVoiceServiceProjectName: String = "SpeechVoiceService"
    
    public static func speechVoiceInterfaceService() -> WMTarget {
        let targetName = "SpeechVoiceInterface"
        return .templateDynamicFrameworkTarget(name: targetName,
                                              projectName: Self.speechVoiceServiceProjectName,
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
    public static func speechVoiceImplementation() -> WMTarget {
        let targetName = "SpeechVoiceImplementation"
        return .templateDynamicFrameworkTarget(name: targetName,
                                               projectName: Self.speechVoiceServiceProjectName,
                                               infoPlist: defaultInfoPlist,
                                               sources: [.path("Implementation/Sources/**")],
                                               resources: [.path("Implementation/Resources/**")],
                                               settings: .appTalkDynamicFramework(targetName),
                                               dependencies: [
                                                .currentTarget(target: Self.speechVoiceInterfaceService()),
                                                .currentTarget(target: .appEntity()),
                                                .currentTarget(target: .accountInterfaceService()),
                                                .currentTarget(target: .clockImplementationService()),
                                               ],
                                               scripts: [])
    }
    
    
    public static func speechVoiceImplementationUnitTest() -> WMTarget {
        let targetName = "SpeechVoiceImplementationUnitTest"
        return .templateUnitTest(name: targetName,
                                 projectName: Self.speechVoiceServiceProjectName,
                                 infoPlist: defaultInfoPlist,
                                 sources: [.path("Implementation/Tests/**")],
                                 settings: .appTalkUnitTestTarget(targetName),
                                 dependencies: [
                                    .currentTarget(target: Self.speechVoiceImplementation())
                                 ],
                                 scripts: [])
    }
}
