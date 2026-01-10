//
//  UIFramework.swift
//  Packages
//
//  Created by 박현수 on 12/21/24.
//

import ProjectDescription

private let uiFrameworkNameAttribute: Template.Attribute = .required("name")

let appTemplate = Template(
    description: "App Template",
    attributes: [
        uiFrameworkNameAttribute,
        .optional("platform", default: "iOS"),
    ],
    items: [
        .file(
            path: "Projects/\(uiFrameworkNameAttribute)/Project.swift",
            templatePath: "AppProject.stencil"
        ),
        
        
        .file(
            path: "Projects/\(uiFrameworkNameAttribute)/Sources/{{ name }}SampleApp.swift",
            templatePath: .relativeToCurrentFile("../../TemplatesSources/SampleApp/SampleApp.stencil")
        ),
        .directory(path: "Projects/\(uiFrameworkNameAttribute)/",
                   sourcePath: .relativeToCurrentFile("../../TemplatesSources/SampleApp/Resources")),
        .directory(path: "Projects/\(uiFrameworkNameAttribute)/",
                   sourcePath: .relativeToCurrentFile("../../TemplatesSources/Feature/Tests")),
    ]
)


