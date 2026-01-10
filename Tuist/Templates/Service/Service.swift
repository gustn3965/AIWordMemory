//
//  Service.swift
//  AIGPTManifests
//
//  Created by 박현수 on 12/22/24.
//

import Foundation
import ProjectDescription

private let serviceFrameworkNameAttribute: Template.Attribute = .required("name")

let serviceFrameworkTemplate = Template(
    description: "DynamicFramework Template",
    attributes: [
        serviceFrameworkNameAttribute,
        .optional("platform", default: "iOS"),
    ],
    items: [
        .file(
            path: "Projects/\(serviceFrameworkNameAttribute)Service/Project.swift",
            templatePath: "ServiceProject.stencil"
        ),
        .directory(path: "Projects/\(serviceFrameworkNameAttribute)Service/Interface/",
                   sourcePath: .relativeToCurrentFile("../../TemplatesSources/Service/Sources")),
        .directory(path: "Projects/\(serviceFrameworkNameAttribute)Service/Interface/",
                   sourcePath: .relativeToCurrentFile("../../TemplatesSources/Service/Resources")),
        .directory(path: "Projects/\(serviceFrameworkNameAttribute)Service/Implementation/",
                   sourcePath: .relativeToCurrentFile("../../TemplatesSources/Service/Sources")),
        .directory(path: "Projects/\(serviceFrameworkNameAttribute)Service/Implementation/",
                   sourcePath: .relativeToCurrentFile("../../TemplatesSources/Service/Resources")),
        .directory(path: "Projects/\(serviceFrameworkNameAttribute)Service/Implementation/",
                   sourcePath: .relativeToCurrentFile("../../TemplatesSources/Service/Tests")),
//        .directory(path: "Projects/\(serviceFrameworkNameAttribute)/Interface/", sourcePath: "Tests"),
    ]
)
