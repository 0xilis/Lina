//
//  ExtractAARShortcutsActionHandler.swift
//  LinaIntents
//
//  Created by Snoolie Keffaber on 2025/05/30.
//

import Intents
import NeoAppleArchive


func captureStderrOutput(perform block: () -> Int32) -> (Int32, String?) {
    let originalStderr = dup(STDERR_FILENO)
    
    var pipeFD: [Int32] = [0, 0]
    pipe(&pipeFD)
    let pipeRead = pipeFD[0]
    let pipeWrite = pipeFD[1]

    dup2(pipeWrite, STDERR_FILENO)
    close(pipeWrite)

    let errorCode = block()

    fflush(stderr)
    dup2(originalStderr, STDERR_FILENO)
    close(originalStderr)

    let bufferSize = 1024
    var buffer = [CChar](repeating: 0, count: bufferSize)
    let bytesRead = read(pipeRead, &buffer, bufferSize - 1)
    close(pipeRead)

    let output = bytesRead > 0 ? String(cString: buffer) : nil
    return (errorCode, output?.trimmingCharacters(in: .whitespacesAndNewlines))
}

class ExtractAARShortcutsActionHandler : NSObject, ExtractAARIntentHandling {
    
    func handle(intent: ExtractAARIntent, completion: @escaping (ExtractAARIntentResponse) -> Void) {
        guard let inputFile = intent.inputPath, let archiveURL = inputFile.fileURL else {
            completion(ExtractAARIntentResponse.failure(error: "No input file provided."))
            return
        }
        
        let fileManager = FileManager.default
        let tempDirectoryURL = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        
        let accessGranted = archiveURL.startAccessingSecurityScopedResource()
        guard accessGranted else {
            completion(ExtractAARIntentResponse.failure(error: "Failed to gain access to archiveURL."))
            return
        }
        
        do {
            try fileManager.createDirectory(at: tempDirectoryURL, withIntermediateDirectories: true)
            
            let isReadable = FileManager.default.isReadableFile(atPath: archiveURL.path)
            if (isReadable == false) {
                completion(ExtractAARIntentResponse.failure(error: "archiveURL.path is not readable (\(archiveURL.path)."))
                return
            }
                
            let (errorCode, stderrOutput) = captureStderrOutput {
                neo_aa_extract_aar_to_path_err(archiveURL.path, tempDirectoryURL.path)
            }
            if (errorCode != 0) {
                let errorMessage = "neo_aa_extract_aar_to_path_err returned code: \(errorCode)." +
                                (stderrOutput.map { " Stderr: \($0)" } ?? "")
                completion(ExtractAARIntentResponse.failure(error: errorMessage))
                return
            }
            
            
            let extractedFiles = try fileManager.contentsOfDirectory(at: tempDirectoryURL, includingPropertiesForKeys: nil)
            
            let outputFiles = extractedFiles.map { fileURL -> INFile in
                return INFile(
                    fileURL: fileURL,
                    filename: fileURL.lastPathComponent,
                    typeIdentifier: "public.data"
                )
            }
            
            archiveURL.stopAccessingSecurityScopedResource()
            
            completion(ExtractAARIntentResponse.success(result: outputFiles))
            
        } catch {
            completion(ExtractAARIntentResponse.failure(error: "Failed to extract archive: \(error.localizedDescription)"))
        }
    }
    
    func resolveInputPath(for intent: ExtractAARIntent, with completion: @escaping (INFileResolutionResult) -> Void) {
        if let inputFile = intent.inputPath {
            completion(INFileResolutionResult.success(with: inputFile))
        } else {
            completion(INFileResolutionResult.needsValue())
        }
    }
}
