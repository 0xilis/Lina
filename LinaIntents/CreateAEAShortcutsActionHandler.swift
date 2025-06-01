//
//  CreateAEAShortcutsActionHandler.swift
//  Lina
//
//  Created by Snoolie Keffaber on 2025/06/01.
//

import Intents
import NeoAppleArchive

class CreateAEAShortcutsActionHandler : NSObject, CreateAEAIntentHandling {
    
    func handle(intent: CreateAEAIntent, completion: @escaping (CreateAEAIntentResponse) -> Void) {
        guard let inputFile = intent.inputFile, let archiveURL = inputFile.fileURL else {
            completion(CreateAEAIntentResponse.failure(error: "No input file provided."))
            return
        }
        
        guard let inputKey = intent.inputKey, let keyURL = inputKey.fileURL else {
            completion(CreateAEAIntentResponse.failure(error: "No input key provided."))
            return
        }
        
        guard let inputAuthData = intent.inputAuthData, let authURL = inputAuthData.fileURL else {
            completion(CreateAEAIntentResponse.failure(error: "No input auth data provided."))
            return
        }
        
        let fileManager = FileManager.default
        let tempDirectoryURL = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        
        do {
            let accessGranted = archiveURL.startAccessingSecurityScopedResource()
            guard accessGranted else {
                completion(CreateAEAIntentResponse.failure(error: "Failed to access inputFile."))
                return
            }
            
            let accessGranted2 = keyURL.startAccessingSecurityScopedResource()
            guard accessGranted2 else {
                completion(CreateAEAIntentResponse.failure(error: "Failed to access inputKey."))
                return
            }
            
            let accessGranted3 = authURL.startAccessingSecurityScopedResource()
            guard accessGranted3 else {
                completion(CreateAEAIntentResponse.failure(error: "Failed to access inputAuthData."))
                return
            }
            
            let keyData = try Data(contentsOf: keyURL)
            let authData = try Data(contentsOf: authURL)
            
            let aeaData = try AEAProfile0Handler_Intents.createAEAFromAAR(aarURL: archiveURL, privateKey: keyData, authData: authData)
            
            let outputFile = INFile(data: aeaData, filename: "Output.aea", typeIdentifier: "com.apple.encrypted-archive")
            
            archiveURL.stopAccessingSecurityScopedResource()
            keyURL.stopAccessingSecurityScopedResource()
            authURL.stopAccessingSecurityScopedResource()
            
            completion(CreateAEAIntentResponse.success(result: outputFile))
        } catch let error as AEAProfile0Handler_Intents.AEAError {
            completion(CreateAEAIntentResponse.failure(error: "AEA error: \(handleAEAError(error))"))
        } catch {
            completion(CreateAEAIntentResponse.failure(error: "Failed to create AEA from AAR."))
            return
        }
    }
    
    func resolveInputFile(for intent: CreateAEAIntent, with completion: @escaping (INFileResolutionResult) -> Void) {
        guard let inputFile = intent.inputFile else {
            completion(INFileResolutionResult.needsValue())
            return
        }

        completion(INFileResolutionResult.success(with: inputFile))
    }
    
    func resolveInputKey(for intent: CreateAEAIntent, with completion: @escaping (INFileResolutionResult) -> Void) {
        guard let inputKey = intent.inputKey else {
            completion(INFileResolutionResult.needsValue())
            return
        }
        
        completion(INFileResolutionResult.success(with: inputKey))
    }
    
    func resolveInputAuthData(for intent: CreateAEAIntent, with completion: @escaping (INFileResolutionResult) -> Void) {
        guard let inputAuthData = intent.inputAuthData else {
            completion(INFileResolutionResult.needsValue())
            return
        }
        
        completion(INFileResolutionResult.success(with: inputAuthData))
    }
}

func handleAEAError(_ error: AEAProfile0Handler_Intents.AEAError) -> String {
    let message: String
    switch error {
    case .invalidKeySize:
        message = "Private key must be 97 bytes (Raw X9.63 ECDSA-P256)"
    case .invalidKeyFormat:
        message = "Invalid ECDSA-P256 key format (Needs Raw X9.63 ECDSA-P256)"
    case .signingFailed:
        message = "Failed to sign archive"
    case .invalidArchive:
        message = "Invalid AAR file"
    case .unsupportedProfile:
        message = "Unsupported AEA profile (Currently only AEAProfile 0 is supported)"
    case .extractionFailed:
        message = "Failed to extract archive"
    }
    return message
}
