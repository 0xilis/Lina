//
//  CreateArchiveShortcutsActionHandler.swift
//  Lina
//
//  Created by Snoolie Keffaber on 2025/05/27.
//

import Intents

class CreateArchiveShortcutsActionHandler : NSObject, CreateAARIntentHandling {
    
    func handle(intent: CreateAARIntent, completion: @escaping (CreateAARIntentResponse) -> Void) {
        if let inputPath = intent.inputPath, let inputDirectory = inputPath.first {
            
            let fileManager = FileManager.default
            let tempDirectoryURL = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
                        
            do {
                /*try fileManager.createDirectory(at: tempDirectoryURL, withIntermediateDirectories: true, attributes: nil)
                            
                let plainArchive = neo_aa_archive_plain_from_directory(inputDirectory.fileURL?.path)
                            
                let outputArchiveURL = tempDirectoryURL.appendingPathComponent("output.aar")
                            
                neo_aa_archive_plain_write_path(plainArchive, outputArchiveURL.path)
                            
                neo_aa_archive_plain_destroy_nozero(plainArchive)
                
                let outputFile = INFile(fileURL: outputArchiveURL, filename: "output.aar", typeIdentifier: "com.apple.archive")
                completion(CreateAppleArchiveIntentResponse.success(result: outputFile))*/
                
                // TODO: Implement NeoAppleArchive
                
                completion(CreateAARIntentResponse.success(result: intent.inputPath![0]))
            } catch {
                completion(CreateAARIntentResponse.failure(error: "Failed to create the archive: \(error.localizedDescription)"))
            }
        } else {
            completion(CreateAARIntentResponse.failure(error: "The entered in file URL was invalid and could not have an Apple Archive created from it."))
        }
    }
    
    /*func handle(intent: CreateAppleArchiveIntent) async -> CreateAppleArchiveIntentResponse {
        <#code#>
    }*/
    
    func resolveInputPath(for intent: CreateAARIntent, with completion: @escaping ([INFileResolutionResult]) -> Void) {

        guard let inputPaths = intent.inputPath else {
            completion([INFileResolutionResult.needsValue()])
            return
        }

        let resolutionResults = inputPaths.map { url -> INFileResolutionResult in
            /*if url.isFileURL {
                return INURLResolutionResult.success(with: url)
            } else {
                print("Unsupported URL: \(url)")
                os_log("(Lina)Unsupported URL: %{public}@", log: OSLog.default, type: .error, url as CVarArg)
                return INURLResolutionResult.unsupported()
            }*/
            return INFileResolutionResult.success(with: url)
        }

        completion(resolutionResults)
    }
    
    /*func resolveInputPath(for intent: CreateAppleArchiveIntent) async -> INURLResolutionResult {
        <#code#>
    }*/
}
