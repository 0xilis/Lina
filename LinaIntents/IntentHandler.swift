//
//  IntentHandler.swift
//  Lina
//
//  Created by Snoolie Keffaber on 2025/05/27.
//

import Intents

func clearTemporaryDirectory() {
    let tempDirectoryURL = FileManager.default.temporaryDirectory
    do {
        let tempDirectoryContents = try FileManager.default.contentsOfDirectory(at: tempDirectoryURL, includingPropertiesForKeys: nil, options: [])
        for fileURL in tempDirectoryContents {
            do {
                try FileManager.default.removeItem(at: fileURL)
            } catch {
                print("Failed to remove file at \(fileURL.path): \(error)")
            }
        }
    } catch {
        print("Failed to read contents of temporary directory: \(error)")
    }
}


class IntentHandler: INExtension {
    
    // Based off example by Alex Hay
    
    override func handler(for intent: INIntent) -> Any {
        clearTemporaryDirectory()
        switch intent {
        case is CreateAARIntent:
            return CreateArchiveShortcutsActionHandler()
        case is ExtractAARIntent:
            return ExtractAARShortcutsActionHandler()
        case is CreateAEAIntent:
            return CreateAEAShortcutsActionHandler()
        case is ExtractAEAIntent:
            return ExtractAEAShortcutsActionHandler()
        default:
            fatalError("No handler for this intent")
        }
    }
}
