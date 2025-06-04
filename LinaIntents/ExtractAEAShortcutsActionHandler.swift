//
//  ExtractAEAShortcutsActionHandler.swift
//  LinaIntents
//
//  Created by Snoolie Keffaber on 2025/06/01.
//

import Intents
import NeoAppleArchive

class ExtractAEAShortcutsActionHandler : NSObject, ExtractAEAIntentHandling {
    func handle(intent: ExtractAEAIntent, completion: @escaping (ExtractAEAIntentResponse) -> Void) {
        guard let inputFile = intent.inputFile, let aeaURL = inputFile.fileURL else {
            completion(ExtractAEAIntentResponse.failure(error: "No input file provided."))
            return
        }
        
        clearTemporaryDirectory()
        
        do {
            let accessGranted = aeaURL.startAccessingSecurityScopedResource()
            guard accessGranted else {
                completion(ExtractAEAIntentResponse.failure(error: "Failed to access aeaURL."))
                return
            }
            
            let aar = try AEAProfile0Handler_Intents.extractAEA(aeaURL: aeaURL)
            
            // Assume output of AEA is an AAR
            let outputFile = INFile(data: aar, filename: "Output.aar", typeIdentifier: "com.apple.archive")
            
            aeaURL.stopAccessingSecurityScopedResource()
            
            completion(ExtractAEAIntentResponse.success(result: outputFile))
        } catch let error as AEAProfile0Handler_Intents.AEAError {
            completion(ExtractAEAIntentResponse.failure(error: "AEA error: \(handleAEAError(error))"))
        } catch {
            completion(ExtractAEAIntentResponse.failure(error: "Failed to extract AEA."))
            return
        }
    }
    
    func resolveInputFile(for intent: ExtractAEAIntent, with completion: @escaping (INFileResolutionResult) -> Void) {
        guard let inputFile = intent.inputFile else {
            completion(INFileResolutionResult.needsValue())
            return
        }
        
        completion(INFileResolutionResult.success(with: inputFile))
    }
    
}
