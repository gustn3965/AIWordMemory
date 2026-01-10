//
//  Feature.swift
//  AIGPTManifests
//
//  Created by 박현수 on 12/22/24.
//


import Foundation
import ProjectDescription

private let FeatureFrameworkNameAttribute: Template.Attribute = .required("name")

let featureFrameworkTemplate = Template(
    description: "DynamicFramework Template",
    attributes: [
        FeatureFrameworkNameAttribute,
        .optional("platform", default: "iOS"),
    ],
    items: [
        .file(
            path: "Projects/\(FeatureFrameworkNameAttribute)Feature/Project.swift",
            templatePath: "FeatureProject.stencil"
        ),
        
        // Sources
        .file(
            path: "Projects/\(FeatureFrameworkNameAttribute)Feature/\(FeatureFrameworkNameAttribute)/Sources/\(FeatureFrameworkNameAttribute)DependencyInjection.swift",
            templatePath: .relativeToCurrentFile("../../TemplatesSources/Feature/DependencyInjection.stencil")
        ),
        .file(
            path: "Projects/\(FeatureFrameworkNameAttribute)Feature/\(FeatureFrameworkNameAttribute)/Sources/\(FeatureFrameworkNameAttribute)SampleView.swift",
            templatePath: .relativeToCurrentFile("../../TemplatesSources/Feature/SampleView.stencil")
        ),
        
        // Resources
        .directory(path: "Projects/\(FeatureFrameworkNameAttribute)Feature/\(FeatureFrameworkNameAttribute)/",
                   sourcePath: .relativeToCurrentFile("../../TemplatesSources/Feature/Resources")),
        .directory(path: "Projects/\(FeatureFrameworkNameAttribute)Feature/\(FeatureFrameworkNameAttribute)/",
                   sourcePath: .relativeToCurrentFile("../../TemplatesSources/Feature/Tests")),
        
        
        .file(
            path: "Projects/\(FeatureFrameworkNameAttribute)Feature/SampleApp/Sources/{{ name }}SampleApp.swift",
            templatePath: .relativeToCurrentFile("../../TemplatesSources/SampleApp/SampleApp.stencil")
        ),
        .directory(path: "Projects/\(FeatureFrameworkNameAttribute)Feature/SampleApp/",
                   sourcePath: .relativeToCurrentFile("../../TemplatesSources/SampleApp/Resources")),
        
        
        //        .directory(path: "Projects/\(FeatureFrameworkNameAttribute)Feature/Interface/",
        //                   sourcePath: .relativeToCurrentFile("../../TemplatesSources/Sources")),
        
        
        //        .directory(path: "Projects/\(FeatureFrameworkNameAttribute)Feature/Implementation/",
        //                   sourcePath: .relativeToCurrentFile("../../TemplatesSources/Sources")),
        //        .directory(path: "Projects/\(FeatureFrameworkNameAttribute)Feature/Implementation/",
        //                   sourcePath: .relativeToCurrentFile("../../TemplatesSources/Resources")),
        //        .directory(path: "Projects/\(FeatureFrameworkNameAttribute)Feature/Implementation/",
        //                   sourcePath: .relativeToCurrentFile("../../TemplatesSources/Tests")),
        //
        //            .directory(path: "Projects/\(FeatureFrameworkNameAttribute)Feature/SampleApp/",
        //                       sourcePath: .relativeToCurrentFile("../../TemplatesSources/Sources")),
        //            .directory(path: "Projects/\(FeatureFrameworkNameAttribute)Feature/SampleApp/",
        //                       sourcePath: .relativeToCurrentFile("../../TemplatesSources/Resources")),
        
        //        .directory(path: "Projects/\(serviceFrameworkNameAttribute)/Interface/", sourcePath: "Tests"),
    ]
)
