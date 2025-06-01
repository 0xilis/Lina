//
//  IntentHandler.swift
//  Lina
//
//  Created by Snoolie Keffaber on 2025/05/27.
//

import Intents

class IntentHandler: INExtension {
    
    // Based off example by Alex Hay
    
    override func handler(for intent: INIntent) -> Any {
        switch intent {
        case is CreateAARIntent:
            return CreateArchiveShortcutsActionHandler()
        case is ExtractAARIntent:
            return ExtractAARShortcutsActionHandler()
        case is CreateAEAIntent:
            return CreateAEAShortcutsActionHandler()
        default:
            fatalError("No handler for this intent")
        }
    }
}
