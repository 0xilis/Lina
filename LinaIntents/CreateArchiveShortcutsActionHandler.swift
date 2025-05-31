//
//  CreateArchiveShortcutsActionHandler.swift
//  Lina
//
//  Created by Snoolie Keffaber on 2025/05/27.
//

import Intents
import NeoAppleArchive

class CreateArchiveShortcutsActionHandler : NSObject, CreateAARIntentHandling {
    
    func handle(intent: CreateAARIntent, completion: @escaping (CreateAARIntentResponse) -> Void) {
        guard let inputPaths = intent.inputPath, !inputPaths.isEmpty else {
            completion(CreateAARIntentResponse.failure(error: "No input files provided."))
            return
        }
        
        let fileManager = FileManager.default
        let tempDirectoryURL = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        do {
            try fileManager.createDirectory(at: tempDirectoryURL, withIntermediateDirectories: true)
                    
            for inputFile in inputPaths {
                guard let inputURL = inputFile.fileURL else {
                    continue
                }

                let accessGranted = inputURL.startAccessingSecurityScopedResource()
                guard accessGranted else {
                    continue
                }

                let destinationURL = tempDirectoryURL.appendingPathComponent(inputURL.lastPathComponent)

                do {
                    try fileManager.copyItem(at: inputURL, to: destinationURL)
                } catch {
                    completion(CreateAARIntentResponse.failure(error: "Failed to copy \(inputURL.path) to \(destinationURL.path): \(error)"))
                    return
                }

                inputURL.stopAccessingSecurityScopedResource()
            }
                    
            let plainArchive = neo_aa_archive_plain_from_directory(tempDirectoryURL.path)
            
            if plainArchive == nil {
                completion(CreateAARIntentResponse.failure(error: "neo_aa_archive_plain_from_directory() function failed for \(tempDirectoryURL.path)."))
                return
            }
            
            var compressionType = NEO_AA_COMPRESSION_NONE
            if intent.compression == .lzfse {
                compressionType = NEO_AA_COMPRESSION_LZFSE
            }
            print("compressionType: \(compressionType)")
                    
            let outputArchiveURL = tempDirectoryURL.appendingPathComponent("output.aar")
            neo_aa_archive_plain_compress_write_path(plainArchive, compressionType, outputArchiveURL.path)
            neo_aa_archive_plain_destroy_nozero(plainArchive)
                    
            let outputFile = INFile(
                fileURL: outputArchiveURL,
                filename: "output.aar",
                typeIdentifier: "com.apple.archive"
            )
                    
            completion(CreateAARIntentResponse.success(result: outputFile))
        } catch {
            completion(CreateAARIntentResponse.failure(error: "Failed to create archive: \(error.localizedDescription)"))
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
            return INFileResolutionResult.success(with: url)
        }

        completion(resolutionResults)
    }
    
    /*func resolveInputPath(for intent: CreateAppleArchiveIntent) async -> INURLResolutionResult {
        <#code#>
    }*/
    
    // For some reason Xcode **REALLY** doesn't like AARCompressionType and says it doesn't exist but it builds fine
    func resolveCompression(for intent: CreateAARIntent, with completion: @escaping (AARCompressionTypeResolutionResult) -> Void) {
        completion(AARCompressionTypeResolutionResult.success(with: intent.compression))
    }
}
