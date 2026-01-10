//
//  Migration.swift
//  DBImplementation
//
//  Created by 박현수 on 12/29/24.
//

import Foundation
import SwiftData

enum WordSchemaV1: VersionedSchema {
    nonisolated(unsafe) static var versionIdentifier: Schema.Version = .init(1, 0, 0)
    
    static var models: [any PersistentModel.Type] {
        [DBWord.self,
         DBWordTag.self,
         DBWordSentence.self,
         DBAccountSetting.self,
         DBWordRecommend.self,
        ]
    }
}

enum WordMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [WordSchemaV1.self]
    }
    
    static var stages: [MigrationStage] {
        []
    }
    
    
    // 예시
//    static var stages: [MigrationStage] {
//        [migrateV1toV2, migrateV2toV3]
//    }
    
//    static let migrateV1toV2 = MigrationStage.custom(
//        fromVersion: WordSchemaV1.versionIdentifier,
//        toVersion: WordSchemaV2.versionIdentifier,
//        transform: { context in
//            try await context.update(Word.self) { oldWord in
//                oldWord.correctCount = 0
//            }
//        }
//    )
//    
//    static let migrateV2toV3 = MigrationStage.custom(
//        fromVersion: WordSchemaV2.versionIdentifier,
//        toVersion: WordSchemaV3.versionIdentifier,
//        transform: { context in
//            // V2에서 V3로의 마이그레이션 로직
//        }
//    )
}

