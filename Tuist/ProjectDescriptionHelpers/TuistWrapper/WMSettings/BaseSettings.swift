//
//  BaseSettings.swift
//  Config
//
//  Created by vapor on 10/11/24.
//

import Foundation


nonisolated(unsafe) public let CURRENT_PROJECT_VERSION = WMSettingValue(stringLiteral: CURRENT_PROJECT_VERSION_VALUE)
nonisolated(unsafe) public let MARKETING_VERSION = WMSettingValue(stringLiteral: MARKETING_VERSION_VALUE)
nonisolated(unsafe) public let SWIFT_VERSION = WMSettingValue(stringLiteral: SWIFT_VERSION_VALUE)

nonisolated(unsafe) let mtBaseVersioning: WMSettingsDictionary = [

    "VERSIONING_SYSTEM": "apple-generic",
    "CURRENT_PROJECT_VERSION": CURRENT_PROJECT_VERSION,
    "MARKETING_VERSION": MARKETING_VERSION,
    
    "IPHONEOS_DEPLOYMENT_TARGET": WMSettingValue(stringLiteral: deploymentTargetiOS),
    "SWIFT_VERSION": SWIFT_VERSION,
]



nonisolated(unsafe) let mtBaseSettings: WMSettingsDictionary = [
    
    "SDKROOT": "iphoneos",
    "EXCLUDED_ARCHS": "",                                 // 빌드시 특정 아키텍처 제거, 나중에 인텔이없어지면 ? intel넣어도될듯 ㅎ
    "ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES": "NO",        // 10.15이상부터는 swift런타임에 포함되어있다고하던데 ? ? NO로 해도될듯... ?
    
    
    // ------------------------------------------------ 고정
    
    "ENABLE_STRICT_OBJC_MSGSEND": "YES",
    "MTL_FAST_MATH": "YES",                 // 수학적연산 빠르게, 게임,그래픽에 유용
    "ALWAYS_SEARCH_USER_PATHS": "NO",
    "SWIFT_EMIT_LOC_STRINGS": "NO",          // 앱에서 로컬라이즈 수동으로하고있으므로, NO로.
    "SWIFT_APPROACHABLE_CONCURRENCY": "YES",
    
    // CLANG apple 최근 컴파일러, GCC 아주 옛날 컴파일러, 이제 기본적으로 CLANG으로 컴파일하는데, 레거시로 GCC도 아직 남아있음.
    
    // CLANG 관련
    "CLANG_ANALYZER_LOCALIZABILITY_NONLOCALIZED": "YES",
    "CLANG_CXX_LANGUAGE_STANDARD": "gnu++0x",   // C++표준지정  -> 공식이름이 gnu11 바꼈다함.
    "CLANG_CXX_LIBRARY": "libc++",
    "CLANG_ENABLE_OBJC_ARC": "YES",
    "CLANG_ENABLE_MODULES": "YES",      // 모듈화?하여 빌드속도 빠르게
    
    // CLANG관련 - 빌드시, 컴파일단 경고 및 에러
    "CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING": "YES",
    "CLANG_WARN_BOOL_CONVERSION": "YES",
    "CLANG_WARN_COMMA": "YES",
    "CLANG_WARN_CONSTANT_CONVERSION": "YES", // 상수 -> 다른타입 변환
    "CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS": "YES",
    "CLANG_WARN_DIRECT_OBJC_ISA_USAGE": "YES_ERROR", // ISA 포인터 사용 X
    "CLANG_WARN_EMPTY_BODY": "YES",
    "CLANG_WARN_ENUM_CONVERSION": "YES",
    "CLANG_WARN_INFINITE_RECURSION": "YES",
    "CLANG_WARN_INT_CONVERSION": "YES",
    "CLANG_WARN_NON_LITERAL_NULL_CONVERSION": "YES",
    "CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF": "YES",
    "CLANG_WARN_OBJC_LITERAL_CONVERSION": "YES",
    "CLANG_WARN_OBJC_ROOT_CLASS": "YES_ERROR",

    "CLANG_WARN_RANGE_LOOP_ANALYSIS": "YES",
    "CLANG_WARN_STRICT_PROTOTYPES": "YES",
    "CLANG_WARN_SUSPICIOUS_MOVE": "YES",
    "CLANG_WARN_UNREACHABLE_CODE": "YES",
    "CLANG_WARN__DUPLICATE_METHOD_MATCH": "YES",
    //    "CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER": "YES",   // cocoapods
    
    
    // GCC관련 (레거시 컴파일러)
    "GCC_C_LANGUAGE_STANDARD": "gnu99", // C 표준지정
    "GCC_ENABLE_OBJC_EXCEPTIONS": "YES",    // Objc 예외처리 사용허용
    "GCC_NO_COMMON_BLOCKS": "YES",          // C의 common blocks 스타일 사용하지않도록
    "GCC_WARN_64_TO_32_BIT_CONVERSION": "YES",
    "GCC_WARN_ABOUT_RETURN_TYPE": "YES_ERROR",
    "GCC_WARN_UNDECLARED_SELECTOR": "YES",
    "GCC_WARN_UNINITIALIZED_AUTOS": "YES",
    "GCC_WARN_UNUSED_FUNCTION": "YES",
    "GCC_WARN_UNUSED_VARIABLE": "YES",
]



// 최적화관련,  디버그, 릴리즈에 따라 다르게
func baseOptimizationSettings(isDebug: Bool) -> WMSettingsDictionary {
    
    return [
        "ONLY_ACTIVE_ARCH": isDebug ? "YES" : "NO" ,                                   // Debug일때는 YES로 해도될듯.
        "SWIFT_OPTIMIZATION_LEVEL": isDebug ? "-Onone" : "-O",                          // 디버그는, -Onone, 릴리즈에서는 -O,
        "SWIFT_COMPILATION_MODE": isDebug ? "singlefile" : "wholemodule",                  // 디버그일때는 incre, 릴리즈일때는 whole  //
        "LLVM_LTO": isDebug ? "NO" : "YES",                                       // 릴리즈에서는 YES로 (Link Time Optimization) 링크타임 최적화
        "STRIP_INSTALLED_PRODUCT": isDebug ? "NO" : "YES",                        // 설치된파일에 심볼제거 (디버깅,분석도구에서 유용),  릴리즈에는 YES로 해도될것같은데, 디심
        "COPY_PHASE_STRIP": isDebug ? "NO" : "YES",                             // 디버그는 NO,
        "GCC_STRICT_ALIASING": isDebug ? "NO" : "YES",                           // 엄격한 규칙, 기존맥은 릴리즈에서만 YES로했음.
        "GCC_OPTIMIZATION_LEVEL": isDebug ? "0" : "s",                         // 릴리즈일때는 os ?
        "DEBUG_INFORMATION_FORMAT": isDebug ? "dwarf" : "dwarf-with-dsym",                       // 릴리즈일때는, dwarf-with-dsym
        "ENABLE_TESTABILITY": isDebug ? "YES" : "NO",                                // UnitTest에서 사용할때, 내부구현접근가능하게함. 릴리즈일때는 NO로.
        "ENABLE_NS_ASSERTIONS": isDebug ? "YES" : "NO",                            // 디버그일때는 YES, 크래쉬나도록.
        "MTL_ENABLE_DEBUG_INFO": isDebug ? "YES" : "NO",                          // 디버그일때는 YES,
        "DEPLOYMENT_POSTPROCESSING" : isDebug ? "NO" : "YES",                       // 후처리,  디버그일때는 NO, 바이너리에 디버그심볼제거,코드최적화,서명강화
    ]
}


// 전처리구문
func basePreprocessor(by config: WMConfiguration) -> WMSettingsDictionary {
    switch config {
    
    // Debug
    case .mockDebug:
        [
            // ----------------Configuration별로 지정필요한항목----------------------
            "GCC_PREPROCESSOR_DEFINITIONS": ["MOCK",
                                             "$(inherited)",
                                             "$(GCC_PREPROCESSOR_DEFINITIONS_SHARED)"],
            "GCC_PREPROCESSOR_DEFINITIONS_SHARED": ["DEBUG",
                                                   "INHOUSE"],
            "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "$(GCC_PREPROCESSOR_DEFINITIONS)",       // 전처리구문
        ]
    case .cbtDebug:
        [
            // ----------------Configuration별로 지정필요한항목----------------------
            "GCC_PREPROCESSOR_DEFINITIONS": ["CBT",
                                             "$(inherited)",
                                             "$(GCC_PREPROCESSOR_DEFINITIONS_SHARED)"],
            "GCC_PREPROCESSOR_DEFINITIONS_SHARED": ["REAL",
                                                    "DEBUG",
                                                    "INHOUSE"],
            "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "$(GCC_PREPROCESSOR_DEFINITIONS)",       // 전처리구문
        ]
    
    case .realDebug:
        [
            // ----------------Configuration별로 지정필요한항목----------------------
            "GCC_PREPROCESSOR_DEFINITIONS": ["REAL",
                                             "$(inherited)",
                                             "$(GCC_PREPROCESSOR_DEFINITIONS_SHARED)"],
            "GCC_PREPROCESSOR_DEFINITIONS_SHARED": ["REAL",
                                                    "DEBUG",
                                                    "INHOUSE"],
            "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "$(GCC_PREPROCESSOR_DEFINITIONS)",       // 전처리구문
        ]
        
        
    // Release
    case .real:
        [
            // ----------------Configuration별로 지정필요한항목----------------------
            "GCC_PREPROCESSOR_DEFINITIONS": ["REAL",
                                             "$(inherited)",
                                             "$(GCC_PREPROCESSOR_DEFINITIONS_SHARED)"],
            "GCC_PREPROCESSOR_DEFINITIONS_SHARED": ["INHOUSE",],
            "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "$(GCC_PREPROCESSOR_DEFINITIONS)",       // 전처리구문
        ]
    case .mock:
        [
            // ----------------Configuration별로 지정필요한항목----------------------
            "GCC_PREPROCESSOR_DEFINITIONS": ["MOCK",
                                             "$(inherited)",
                                             "$(GCC_PREPROCESSOR_DEFINITIONS_SHARED)"],
            "GCC_PREPROCESSOR_DEFINITIONS_SHARED": ["INHOUSE",],
            "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "$(GCC_PREPROCESSOR_DEFINITIONS)",       // 전처리구문
        ]
    case .cbt:
        [
            // ----------------Configuration별로 지정필요한항목----------------------
            "GCC_PREPROCESSOR_DEFINITIONS": ["CBT",
                                             "$(inherited)",
                                             "$(GCC_PREPROCESSOR_DEFINITIONS_SHARED)"],
            "GCC_PREPROCESSOR_DEFINITIONS_SHARED": ["REAL", "INHOUSE",],
            "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "$(GCC_PREPROCESSOR_DEFINITIONS)",       // 전처리구문
        ]
    }
}
