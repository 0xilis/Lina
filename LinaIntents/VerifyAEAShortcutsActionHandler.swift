//
//  VerifyAEAShortcutsActionHandler.swift
//  LinaIntents
//
//  Created by Snoolie Keffaber on 2025/06/13.
//

import Intents
import NeoAppleArchive

class VerifyAEAShortcutsActionHandler : NSObject, VerifyAEAIntentHandling {
    
    func handle(intent: VerifyAEAIntent, completion: @escaping (VerifyAEAIntentResponse) -> Void) {
        guard let inputFile = intent.inputFile, let aeaURL = inputFile.fileURL else {
            completion(VerifyAEAIntentResponse.failure(error: "No input files provided."))
            return
        }
        
        guard let inputKey = intent.inputKey, let keyURL = inputKey.fileURL else {
            completion(VerifyAEAIntentResponse.failure(error: "No input key provided."))
            return
        }
        
        do {
            let securityAccessGranted = aeaURL.startAccessingSecurityScopedResource()
            guard securityAccessGranted else {
                completion(VerifyAEAIntentResponse.failure(error: "Could not access aeaURL."))
                return
            }
            let keyAccessGranted = keyURL.startAccessingSecurityScopedResource()
            guard keyAccessGranted else {
                completion(VerifyAEAIntentResponse.failure(error: "Could not access keyURL."))
                return
            }
            
            let verified = try AEAProfile0Handler_Intents.verifyAEA(aeaURL: aeaURL, keyURL: keyURL)
            
            aeaURL.stopAccessingSecurityScopedResource()
            keyURL.stopAccessingSecurityScopedResource()
            
            if verified {
                completion(VerifyAEAIntentResponse.success(result: "AEA is verified."))
            }
            
            completion(VerifyAEAIntentResponse.success(result: "AEA is not verified."))
        } catch let error as AEAProfile0Handler_Intents.AEAError {
            aeaURL.stopAccessingSecurityScopedResource()
            keyURL.stopAccessingSecurityScopedResource()
            completion(VerifyAEAIntentResponse.failure(error: "AEA Error: \(handleAEAError(error))"))
        } catch {
            completion(VerifyAEAIntentResponse.failure(error: "Failed to extract archive: \(error.localizedDescription)"))
        }
    }
    
    func resolveInputFile(for intent: VerifyAEAIntent, with completion: @escaping (INFileResolutionResult) -> Void) {
        if let inputFile = intent.inputFile {
            completion(INFileResolutionResult.success(with: inputFile))
        } else {
            completion(INFileResolutionResult.needsValue())
        }
    }
    
    func resolveInputKey(for intent: VerifyAEAIntent, with completion: @escaping (INFileResolutionResult) -> Void) {
        if let inputKey = intent.inputKey {
            completion(INFileResolutionResult.success(with: inputKey))
        } else {
            completion(INFileResolutionResult.needsValue())
        }
    }
}
