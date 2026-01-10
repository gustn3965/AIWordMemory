// swift-tools-version: 6.0
import PackageDescription

#if TUIST
    import struct ProjectDescription.PackageSettings

    let packageSettings = PackageSettings(
        productTypes: [
            "GoogleMobileAds": .staticLibrary
        ],
        baseSettings: .settings(configurations: [
            
            .debug(name: "Mock(Debug)"),
            .debug(name: "CBT(Debug)"),
            .debug(name: "Real(Debug)"),
            .release(name: "Mock"),
            .release(name: "CBT"),
            .release(name: "Real")
            
        ])
    )
#endif

nonisolated(unsafe) let package = Package(
    name: "AIWordMemory",
    dependencies: [
        // 이름은 https://swiftpackageregistry.com 여기서확인가능
        .package(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git", from: .init(11, 6, 0)),
        .package(url: "https://github.com/MobileNativeFoundation/Kronos.git", from: .init(4, 3, 1))
        
        
        // Add your own dependencies here:
        // .package(url: "https://github.com/Alamofire/Alamofire", from: "5.0.0"),
        // You can read more about dependencies here: https://docs.tuist.io/documentation/tuist/dependencies
    ]
)
