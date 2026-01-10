//
//  AppTalkUnitTestBase.swift
//  ProjectDescriptionHelpers
//
//  Created by vapor on 10/11/24.
//

import Foundation


func baseAppTalkUnitTestSettings() -> WMSettingsDictionary {
    return [
        "GENERATE_INFOPLIST_FILE": "YES",
        "WRAPPER_EXTENSION": "xctest",                                 // 빌드된 번들 확장자
        "SKIP_INSTALL": "YES",
        "ENABLE_HARDENED_RUNTIME": "NO",                       // 런타임 보안 강화 (Sandbox, 코드서명 .. )
        
        // 런타임, 헤더, 라이브러리, 프레임워크
        "LD_RUNPATH_SEARCH_PATHS": ["$(inherited)"],                             // 런타임때 동적 프레임워크찾는경로
        "FRAMEWORK_SEARCH_PATHS": ["$(inherited)",                              // 컴파일시, 링커가 프레임워크 찾는 경로

                                  ],
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
//                               ],
        "LIBRARY_SEARCH_PATHS": [                                               // 컴파일시, 링커가 라이브러리 찾는 경로
        ],
        
        "GCC_PRECOMPILE_PREFIX_HEADER": "NO",              // MacTalk-Prefix 미리 컴파일, objective-c다 없어지면 NO로해도될듯.
        "GCC_PREFIX_HEADER": "",
        "SWIFT_OBJC_BRIDGING_HEADER": "",                   // objective-c코드없어지면 없애도.
        "WARNING_CFLAGS": "",                                // objc 컴파일러 경고, objc없으면 경고없애라는 걸로바꿔야할듯, -Wno-nullability-completeness ?
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
        "DEFINES_MODULE": "NO",                                 // 타겟을 모듈화로만들어, import가능해짐
        
        
        // User-Defined
        
    ]
}
