//
//  AppTalkDynamicFrameworkBase.swift
//  ProjectDescriptionHelpers
//
//  Created by vapor on 12/23/24.
//

import Foundation

func baseAppDynamicSettings() -> WMSettingsDictionary {
    return [
//        "WRAPPER_EXTENSION": "framework",                                 // 빌드된 번들 확장자 ( Tuist-product에 따라 달라짐 )
        "SKIP_INSTALL": "YES",      // dynamicdms YES로 해야 Archive시에 이슈없음..  https://developer.apple.com/documentation/technotes/tn3110-resolving-generic-xcode-archive-issue#Ensure-the-Skip-Install-build-setting-is-properly-configured
        "ENABLE_HARDENED_RUNTIME": "YES",                       // 런타임 보안 강화 (Sandbox, 코드서명 .. )
        // 런타임, 헤더, 라이브러리, 프레임워크
        "LD_RUNPATH_SEARCH_PATHS": ["$(inherited)"],                           // 런타임때 동적 프레임워크찾는경로
        "FRAMEWORK_SEARCH_PATHS": ["$(inherited)",                              // 컴파일시, 링커가 프레임워크 찾는 경로
                                   
                                   
//                                   "$(PROJECT_DIR)/Libraries/Vox",            // dependencies로추가할때 Tuist에서 경로찾아줌.
//                                   "$(PROJECT_DIR)/Frameworks"
                                  ],
        // 프로젝트 외부 헤더파일검색경로.
//        "HEADER_SEARCH_PATHS": ["$(inherited)",                                 // 컴파일시, 링커가 헤더파일 찾는 경로
//                                "$(PROJECT_DIR)/../../Libraries/SSL",
//                                "${PODS_ROOT}/Headers/Public",
//                                "${PODS_ROOT}/Headers/Public/AFNetworking",
//                                "${PODS_ROOT}/Headers/Public/CocoaAsyncSocket",
//                                "${PODS_ROOT}/Headers/Public/CocoaLumberjack",
//                                "${PODS_ROOT}/Headers/Public/FMDB",
//                                "${PODS_ROOT}/Headers/Public/KVOController",
//                                "${PODS_ROOT}/Headers/Public/SGJsonKit",
//                                "${PODS_ROOT}/Headers/Public/SQLCipher",
//                                "${PODS_ROOT}/Headers/Public/objective-zip",
//                                "${SDKROOT}/usr/include/libxml2",
//                                ],
        "LIBRARY_SEARCH_PATHS": ["$(inherited)",                                     // 컴파일시, 링커가 라이브러리 찾는 경로
                                 
//                                 "$(PROJECT_DIR)/Libraries/Vox/lib/release"             // dependencies로추가할때 Tuist에서 경로찾아줌.
                                 
                                ],

        "GCC_PRECOMPILE_PREFIX_HEADER": "NO",              // MacTalk-Prefix 미리 컴파일, objective-c다 없어지면 NO로해도될듯.
//        "GCC_PREFIX_HEADER": "MacTalk/MacTalk-Prefix.pch",
//        "SWIFT_OBJC_BRIDGING_HEADER": "MacTalk/Swift/MacTalk-Bridging-Header.h",        // objective-c코드없어지면 없애도.
//        "WARNING_CFLAGS": "-Wobjc-signed-char-bool-implicit-int-conversion",            // objc 컴파일러 경고, objc없으면 경고없애라는 걸로바꿔야할듯, -Wno-nullability-completeness ?
        // 링커(LD)에 전달할 추가 플래그를 지정합니다.
        // 프로젝트에서 특정 라이브러리나 프레임워크를 사용하기 위해, 링커에 해당 라이브러리나 프레임워크를 명시적으로 지정합니다.
        "OTHER_LDFLAGS": ["$(inherited)",
                          "-ObjC", "-l\"z\"",
                          "-framework",
                          "CoreServices",
                          "-framework",
                          "Security",
                          "-framework",
                          "SystemConfiguration",
                          "-lxml2"],
        "OTHER_CFLAGS": ["$(inherited)",],
        "DEFINES_MODULE": "YES",                                 // 타겟을 모듈화로만들어, import가능해짐
        
        
    ]
}
