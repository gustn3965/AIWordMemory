//
//  TuistWrapper+Project.swift
//  ProjectDescriptionHelpers
//
//  Created by vapor on 10/13/24.
//

import Foundation
import ProjectDescription


extension Project {
    
    public static func makeWM(_ talkProject: WMProject) -> Project {
        
        let name = talkProject.name
        let options: Project.Options = .options(
            automaticSchemesOptions: .disabled,
//            defaultKnownRegions: ["en", "ko"],
            disableSynthesizedResourceAccessors: true
        )
        let settings = talkProject.settings.tuist()
        let targets = talkProject.targets.map { $0.tuist() }
        
        let schemes = talkProject.schemes.map { $0.tuist() }
        
        return .init(name: name,
                     options: options,
                     settings: settings,
                     targets: targets,
                     schemes: schemes)
//        return project
    }
}

extension WMTarget {
    
    func tuist() -> Target {
        let name = name
        let destinations = destinations.tuist()
        let product = product.tuist()
        let deploymentTargets = depolymentTargets.tuist()
        let sources = sources.map { $0.tuist() }
        let resources = resources.map { $0.tuist() }
        let scripts = scripts.map { $0.tuist() }
        let dependencies = dependencies.map { $0.tuist() }
        let headers = headers.map { $0.tuist() }
        let additionalFiles = additionalFiles.map { $0.additionalFilesTuist() }
        let settings = settings.tuist()
        
        var tuistInfoPlist: [String: Plist.Value] = [:]
        infoPlist.forEach { tuistInfoPlist[$0.key] = Plist.Value(stringLiteral: $0.value)}
        tuistInfoPlist["NSAppTransportSecurity"] = Plist.Value(dictionaryLiteral: ("NSAllowsArbitraryLoadsForMedia", "YES"), ("NSAllowsArbitraryLoadsInWebContent", "YES"))
        
        tuistInfoPlist["GADApplicationIdentifier"] = "ca-app-pub-1390449059923047~6702382018"
        tuistInfoPlist["SKAdNetworkItems"] = Plist.Value(arrayLiteral: [
            .dictionary(["SKAdNetworkIdentifier": "cstr6suwn9.skadnetwork"]),
            .dictionary(["SKAdNetworkIdentifier": "4fzdc2evr5.skadnetwork"]),
            .dictionary(["SKAdNetworkIdentifier": "2fnua5tdw4.skadnetwork"]),
            .dictionary(["SKAdNetworkIdentifier": "ydx93a7ass.skadnetwork"]),
            .dictionary(["SKAdNetworkIdentifier": "p78axxw29g.skadnetwork"]),
            .dictionary(["SKAdNetworkIdentifier": "v72qych5uu.skadnetwork"]),
            .dictionary(["SKAdNetworkIdentifier": "ludvb6z3bs.skadnetwork"]),
            .dictionary(["SKAdNetworkIdentifier": "cp8zw746q7.skadnetwork"]),
            .dictionary(["SKAdNetworkIdentifier": "3sh42y64q3.skadnetwork"]),
            .dictionary(["SKAdNetworkIdentifier": "c6k4g5qg8m.skadnetwork"]),
            .dictionary(["SKAdNetworkIdentifier": "s39g8k73mm.skadnetwork"]),
            .dictionary(["SKAdNetworkIdentifier": "3qy4746246.skadnetwork"]),
            .dictionary(["SKAdNetworkIdentifier": "hs6bdukanm.skadnetwork"]),
            .dictionary(["SKAdNetworkIdentifier": "mlmmfzh3r3.skadnetwork"]),
            .dictionary(["SKAdNetworkIdentifier": "v4nxqhlyqp.skadnetwork"]),
            .dictionary(["SKAdNetworkIdentifier": "wzmmz9fp6w.skadnetwork"]),
            .dictionary(["SKAdNetworkIdentifier": "su67r6k2v3.skadnetwork"]),
            .dictionary(["SKAdNetworkIdentifier": "yclnxrl5pm.skadnetwork"]),
            .dictionary(["SKAdNetworkIdentifier": "7ug5zh24hu.skadnetwork"]),
            .dictionary(["SKAdNetworkIdentifier": "gta9lk7p23.skadnetwork"]),
            .dictionary(["SKAdNetworkIdentifier": "vutu7akeur.skadnetwork"]),
            .dictionary(["SKAdNetworkIdentifier": "y5ghdn5j9k.skadnetwork"]),
            .dictionary(["SKAdNetworkIdentifier": "v9wttpbfk9.skadnetwork"]),
            .dictionary(["SKAdNetworkIdentifier": "n38lu8286q.skadnetwork"]),
            .dictionary(["SKAdNetworkIdentifier": "47vhws6wlr.skadnetwork"]),
            .dictionary(["SKAdNetworkIdentifier": "kbd757ywx3.skadnetwork"]),
            .dictionary(["SKAdNetworkIdentifier": "9t245vhmpl.skadnetwork"]),
            .dictionary(["SKAdNetworkIdentifier": "a2p9lx4jpn.skadnetwork"]),
            .dictionary(["SKAdNetworkIdentifier": "22mmun2rn5.skadnetwork"]),
            .dictionary(["SKAdNetworkIdentifier": "4468km3ulz.skadnetwork"]),
            .dictionary(["SKAdNetworkIdentifier": "2u9pt9hc89.skadnetwork"]),
            .dictionary(["SKAdNetworkIdentifier": "8s468mfl3y.skadnetwork"]),
            .dictionary(["SKAdNetworkIdentifier": "ppxm28t8ap.skadnetwork"]),
            .dictionary(["SKAdNetworkIdentifier": "uw77j35x4d.skadnetwork"]),
            .dictionary(["SKAdNetworkIdentifier": "pwa73g5rt2.skadnetwork"]),
            .dictionary(["SKAdNetworkIdentifier": "578prtvx9j.skadnetwork"]),
            .dictionary(["SKAdNetworkIdentifier": "4dzt52r2t5.skadnetwork"]),
            .dictionary(["SKAdNetworkIdentifier": "tl55sbb4fm.skadnetwork"]),
            .dictionary(["SKAdNetworkIdentifier": "e5fvkxwrpn.skadnetwork"]),
            .dictionary(["SKAdNetworkIdentifier": "8c4e2ghe7u.skadnetwork"]),
            .dictionary(["SKAdNetworkIdentifier": "3rd42ekr43.skadnetwork"]),
            .dictionary(["SKAdNetworkIdentifier": "3qcr597p9d.skadnetwork"])
        ])

        return Target.target(name: name,
                             destinations: destinations,
                             product: product,
                             bundleId: "${PRODUCT_BUNDLE_IDENTIFIER}",
                             deploymentTargets: deploymentTargets,
                             infoPlist: .extendingDefault(with: tuistInfoPlist),                // build settings에서 관리
                             sources: .sourceFilesList(globs: sources),
                             resources: .resources(resources),
                             copyFiles: nil,
                             headers: .headers(
                                public: .list(headers)
                             ),
                             entitlements: nil,             // build settings에서 관리
                             scripts: scripts,
                             dependencies: dependencies,
                             settings: settings,
                             coreDataModels: [],
                             environmentVariables: [:],
                             launchArguments: [],
                             additionalFiles: additionalFiles,
                             buildRules: [],
                             mergedBinaryType: .disabled,
                             mergeable: false,
                             onDemandResourcesTags: nil)
    }
}


extension WMTarget.Product {
    func tuist() -> Product {
        switch self {
        case .app:
            return .app
        case .appUnitTest:
            return .unitTests
        case .appHelper:
            return .app
        case .appShare:
            return .appExtension
        case .dynamicFramework:
            return .framework
        case .staticFramework:
            return .staticFramework
        }
    }
}

extension WMTarget.DeployTargets {
    func tuist() -> DeploymentTargets {
        switch self {
        case .iOS(let version):
            return .iOS(version)
        }
    }
}

extension WMTarget.Destinations {
    func tuist() -> Destinations {
        switch self {
        case .iOS:
            return .iOS
        }
    }
}


extension Dictionary where Key == String, Value == WMSettingValue  {
    func tuist() -> SettingsDictionary {
        var dictionary: SettingsDictionary = [:]
        forEach { key, value  in
            switch value {
            case .array(let array):
                dictionary[key] = .array(array)
            case .string(let string):
                dictionary[key] = .string(string)
            }
        }
        return dictionary
    }
}

extension WMSettings {
    
    func tuist() -> ProjectDescription.Settings {
        
        var result: [ProjectDescription.Configuration] = []
        
        self.configurations.forEach { config in
            let name = config.configuration.configurationName
            
            let dictionary: SettingsDictionary = config.dictionary.tuist()
            let path = config.xcconfigPath?.tuist()
            if config.isDebug {
                result.append(.debug(name: ConfigurationName(stringLiteral: name),
                                     settings: dictionary,
                                     xcconfig: path))
            } else {
                result.append(.release(name: ConfigurationName(stringLiteral: name),
                                       settings: dictionary,
                                       xcconfig: path))
            }
        }
        
        return .settings(configurations: result,
                         defaultSettings: .recommended(excluding:  ["ASSETCATALOG_COMPILER_APPICON_NAME",
                                                                    "PRODUCT_NAME",
                                                                    "PRODUCT_BUNDLE_IDENTIFIER",
                                                                    "CODE_SIGN_IDENTITY"]))
    }
}


extension WMSourceFileList {
    
    func tuist() -> SourceFileGlob {
        // SourceFileGlob
        
        if excluding.isEmpty {
            return .glob(path.tuist(), compilerFlags: compilerFlags)
        } else {
            return .glob(path.tuist(), excluding: excluding.map { $0.tuist()})
        }
    }
}
extension WMResourceFileList {
    func tuist() -> ResourceFileElement {
        // ResourceFileElement
        if excluding.isEmpty {
            return .glob(pattern: path.tuist())
        } else {
            return .glob(pattern: path.tuist(), excluding: excluding.map { $0.tuist() })
        }
    }
}
extension WMHeaders {
    func tuist() -> FileListGlob {
        // FileListGlob
        return .glob(path.tuist())
    }
}

extension WMPath {
    
    func tuist() -> ProjectDescription.Path {
        switch self {
        case .relativeToManifest(let path):
            return .relativeToManifest(path)
        case .relativeToRoot(let path):
            return .relativeToRoot(path)
        }
    }
    
    func additionalFilesTuist() -> FileElement {
        return .glob(pattern: tuist())
    }
}

extension WMScheme {
    
    func tuist() -> ProjectDescription.Scheme {
        let buildTargets = buildTargets.map { ProjectDescription.TargetReference(stringLiteral: $0.name)}
        let testTargets = testTargets.map { ProjectDescription.TestableTarget(stringLiteral: $0.name)}
        
        let buildTargetsNames = buildTargets.map { $0.targetName }.joined(separator: ", ")
        return .scheme(
            name: "\(projectName) - \(buildTargetsNames) - \(configuration.schemeName)",
            shared: true,
            buildAction: .buildAction(targets: buildTargets),
            testAction: .targets(testTargets, configuration: .init(stringLiteral: configuration.configurationName)),
            runAction: .runAction(configuration: .init(stringLiteral: configuration.configurationName)),
            archiveAction: .archiveAction(configuration: .init(stringLiteral: configuration.configurationName),
                                          customArchiveName: "\(projectName) - \(buildTargetsNames) - \(configuration.schemeName)"),
            profileAction: .profileAction(configuration: .init(stringLiteral: configuration.configurationName)),
            analyzeAction: .analyzeAction(configuration: .init(stringLiteral: configuration.configurationName))
        )
    }
}

extension WMTargetDependencies {
    func tuist() -> TargetDependency {
        switch self {
        case .target(let targetName):
            return .target(name: targetName)
        case .xcframework(let path):
            return .xcframework(path: path.tuist())
        case .framework(let path):
            return .framework(path: path.tuist())
        case .sdk(let name, let type):
            return .sdk(name: name, type: type.tuist())
        case .library(let path, let publicHeaders):
            return .library(path: path.tuist(), publicHeaders: publicHeaders.tuist(), swiftModuleMap: nil)
        case .spm(name: let spm):
            if spm == "GoogleMobileAds" {
                return .external(name: "GoogleMobileAds", condition: .none)
            } else {
                return .external(name: spm, condition: .none)
            }
            
            
        case .project(let targetName):
            return .project(target: targetName, path: .relativeToRoot("Projects/ReviewFeature"))
            
            
        // tuist로 생성된 프로젝트-타겟.
        case .currentTarget(let target):
//            return .target(name: target.name)
            return .project(target: target.name, path: .relativeToRoot("Projects/\(target.projectName)"))
        }
        
    }
}

extension WMSDKType {
    func tuist() -> SDKType {
        switch self {
        case .library:
            return .library
        case .swiftLibrary:
            return .swiftLibrary
        case .framework:
            return .framework
        }
    }
}
extension WMTargetScript {
    func tuist() -> TargetScript {
        if isPreOrder {
            return .pre(script: script, name: name, basedOnDependencyAnalysis: basedOnDependencyAnalysis, runForInstallBuildsOnly: runForInstallBuildsOnly)
        } else {
            return .post(script: script, name: name, basedOnDependencyAnalysis: basedOnDependencyAnalysis, runForInstallBuildsOnly: runForInstallBuildsOnly)
        }
    }
}
