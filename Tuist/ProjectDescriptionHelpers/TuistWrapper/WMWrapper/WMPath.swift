//
//  WMPath.swift
//  ProjectDescriptionHelpers
//
//  Created by vapor on 10/13/24.
//

import Foundation




public enum WMPath: ExpressibleByStringInterpolation {
    case relativeToRoot(String)
    case relativeToManifest(String)
    
    public init(stringLiteral value: StringLiteralType) {
        self = .relativeToManifest(value)
    }
    
}

public struct WMSourceFileList {
    var path: WMPath
    var excluding: [WMPath]
    var compilerFlags: String?
    
    public static func path(_ path: WMPath, compilerFlags: String? = nil) -> WMSourceFileList {
        WMSourceFileList(path: path, excluding: [], compilerFlags: compilerFlags)
    }
    
    public static func path(_ path: WMPath, excluding: [WMPath]) -> WMSourceFileList {
        WMSourceFileList(path: path, excluding: excluding, compilerFlags: nil)
    }
}


public struct WMResourceFileList {
    var path: WMPath
    var excluding: [WMPath]
    
    public static func path(_ path: WMPath) -> WMResourceFileList {
        WMResourceFileList(path: path, excluding: [])
    }
    
    public static func path(_ path: WMPath, excluding: [WMPath]) -> WMResourceFileList {
        WMResourceFileList(path: path, excluding: excluding)
    }
}


public struct WMHeaders {
    var path: WMPath
    
    public static func path(_ path: WMPath) -> WMHeaders {
        WMHeaders(path: path)
    }
}
