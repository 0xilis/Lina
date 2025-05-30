//
//  ExtractAARShortcutsActionHandler.swift
//  LinaIntents
//
//  Created by Snoolie Keffaber on 2025/05/30.
//

import Intents
import NeoAppleArchive

class ExtractAARShortcutsActionHandler : NSObject, ExtractAARIntentHandling {
    
    func handle(intent: ExtractAARIntent, completion: @escaping (ExtractAARIntentResponse) -> Void) {
        completion(ExtractAARIntentResponse.failure(error: "TESTING (ACTION NOT YET COMPLETE)"))
        
        return
        /*guard let inputFile = intent.inputPath, let archiveURL = inputFile.fileURL else {
            completion(ExtractAARIntentResponse.failure(error: "No input file provided."))
            return
        }
        
        let fileManager = FileManager.default
        let tempDirectoryURL = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        
        do {
            if !fileManager.fileExists(atPath: tempDirectoryURL.path) {
                try fileManager.createDirectory(at: tempDirectoryURL, withIntermediateDirectories: true)
            }
            
            neo_aa_extract_aar_to_path(archiveURL.path, tempDirectoryURL.path)
            // TODO: In the future, detect if neo_aa_extract_aar_to_path fails, if so error with "Failed to extract archive."
            
            let extractedFiles = try fileManager.contentsOfDirectory(at: tempDirectoryURL, includingPropertiesForKeys: nil)
            
            let outputFiles = extractedFiles.map { fileURL -> INFile in
                return INFile(
                    fileURL: fileURL,
                    filename: fileURL.lastPathComponent,
                    typeIdentifier: "public.data"
                )
            }
            
            completion(ExtractAARIntentResponse.success(result: outputFiles))
            
        } catch {
            completion(ExtractAARIntentResponse.failure(error: "Failed to extract archive: \(error.localizedDescription)"))
        }*/
    }
    
    func resolveInputPath(for intent: ExtractAARIntent, with completion: @escaping (INFileResolutionResult) -> Void) {
        if let inputFile = intent.inputPath {
            completion(INFileResolutionResult.success(with: inputFile))
        } else {
            completion(INFileResolutionResult.needsValue())
        }
    }
}
