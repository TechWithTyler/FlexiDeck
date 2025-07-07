//
//  ExportedDeck.swift
//  FlexiDeck
//
//  Created by Tyler Sheft on 7/4/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct ExportedDeck: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    var data: Data

    init(data: Data) {
        self.data = data
    }

    init(configuration: ReadConfiguration) throws {
        self.data = configuration.file.regularFileContents ?? Data()
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: data)
    }
}
