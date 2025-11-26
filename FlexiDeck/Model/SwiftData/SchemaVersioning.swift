//
//  SchemaVersioning.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 8/16/24.
//  Copyright © 2024-2025 SheftApps. All rights reserved.
//

// MARK: - Imports

import SwiftData

struct FlexiDeckMigrationPlan: SchemaMigrationPlan {

    // MARK: - Properties - Schemas

    // The versioned schemas for the migration plan.
    static var schemas: [VersionedSchema.Type] = [
        FlexiDeckVersionedSchemaV1.self
        // Create new versioned schemas and add them here if the data model changes between releases.
    ]

    // MARK: - Properties - Migration Stages

    static var stages: [MigrationStage] = [
        // Stages of migration between VersionedSchema, if required.
    ]

}

struct FlexiDeckVersionedSchemaV1: VersionedSchema {

    // MARK: - Properties - Version

    // The version number of the schema.
    static var versionIdentifier = Schema.Version(1, 0, 0)

    // MARK: - Properties - Models

    // The models in the schema.
    static var models: [any PersistentModel.Type] = [
        Deck.self,
        Card.self
    ]

}

