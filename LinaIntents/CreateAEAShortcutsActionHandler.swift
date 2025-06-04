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
        
        let fileCoordinator = NSFileCoordinator()
        
        fileCoordinator.coordinate(readingItemAt: archiveURL, options: .withoutChanges, error: nil) { (coordinatedArchiveURL) in
            fileCoordinator.coordinate(readingItemAt: keyURL, options: .withoutChanges, error: nil) { (coordinatedKeyURL) in
                fileCoordinator.coordinate(readingItemAt: authURL, options: .withoutChanges, error: nil) { (coordinatedAuthURL) in
                    do {
                        // Access security-scoped resources
                        let archiveAccess = coordinatedArchiveURL.startAccessingSecurityScopedResource()
                        let keyAccess = coordinatedKeyURL.startAccessingSecurityScopedResource()
                        let authAccess = coordinatedAuthURL.startAccessingSecurityScopedResource()
                        
                        guard archiveAccess && keyAccess && authAccess else {
                            completion(CreateAEAIntentResponse.failure(error: "Failed to access files."))
                            return
                        }
                        
                        // Read file contents
                        let keyData = try Data(contentsOf: coordinatedKeyURL)
                        let authData = try Data(contentsOf: coordinatedAuthURL)
                        
                        // Create AEA
                        let aeaData = try AEAProfile0Handler_Intents.createAEAFromAAR(
                            aarURL: coordinatedArchiveURL,
                            privateKey: keyData,
                            authData: authData
                        )
                        
                        // Create output file
                        let outputFile = INFile(
                            data: aeaData,
                            filename: "EncryptedArchive.aea",
                            typeIdentifier: "com.apple.encrypted-archive"
                        )
                        
                        // Release resources
                        coordinatedArchiveURL.stopAccessingSecurityScopedResource()
                        coordinatedKeyURL.stopAccessingSecurityScopedResource()
                        coordinatedAuthURL.stopAccessingSecurityScopedResource()
                        
                        completion(CreateAEAIntentResponse.success(result: outputFile))
                    } catch let error as AEAProfile0Handler_Intents.AEAError {
                        coordinatedArchiveURL.stopAccessingSecurityScopedResource()
                        coordinatedKeyURL.stopAccessingSecurityScopedResource()
                        coordinatedAuthURL.stopAccessingSecurityScopedResource()
                        completion(CreateAEAIntentResponse.failure(error: "AEA Error: \(handleAEAError(error))"))
                    } catch {
                        coordinatedArchiveURL.stopAccessingSecurityScopedResource()
                        coordinatedKeyURL.stopAccessingSecurityScopedResource()
                        coordinatedAuthURL.stopAccessingSecurityScopedResource()
                        completion(CreateAEAIntentResponse.failure(error: "Failed to create AEA: \(error.localizedDescription)"))
                    }
                }
            }
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

class FileAccessCoordinator: NSObject, NSFilePresenter {
    var presentedItemURL: URL?
    let presentedItemOperationQueue = OperationQueue.main
    
    init(fileURL: URL? = nil) {
        self.presentedItemURL = fileURL
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
