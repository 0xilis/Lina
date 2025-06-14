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

// TODO: i hate this but I need to do it like this so if a shortcut needs to access the output of an action which is in a temp directory afterwards, it doesn't bring any errors. look into better ways to do this...
var clearedTemporaryDirectory = false

class IntentHandler: INExtension {
    
    // Based off example by Alex Hay
    
    override func handler(for intent: INIntent) -> Any {
        if !clearedTemporaryDirectory {
            clearTemporaryDirectory()
            clearedTemporaryDirectory = true
        }
        switch intent {
        case is CreateAARIntent:
            return CreateArchiveShortcutsActionHandler()
        case is ExtractAARIntent:
            return ExtractAARShortcutsActionHandler()
        case is CreateAEAIntent:
            return CreateAEAShortcutsActionHandler()
        case is ExtractAEAIntent:
            return ExtractAEAShortcutsActionHandler()
        case is VerifyAEAIntent:
            return VerifyAEAShortcutsActionHandler()
        default:
            fatalError("No handler for this intent")
        }
    }
}
