//
//  CreateArchiveShortcutsActionHandler.swift
//  Lina
//
//  Created by Snoolie Keffaber on 2025/05/27.
//

import Intents
import NeoAppleArchive

class AEAProfile0Handler_Intents {
    static func createAEAFromAAR(aarURL: URL, privateKey: Data, authData: Data) throws -> Data {
        guard privateKey.count == 97 else {
            throw AEAError.invalidKeySize
        }
        
        let aarData = try Data(contentsOf: aarURL)
        
        /*
         * TODO: Awful hack...
         * Currently, sign_aea_with_private_key_and_auth_data
         * frees the first argument, so to use it with Swift
         * we need to allocate it ourselfs and ensure Swift's
         * auto memory management doesn't try to free() it.
         * since this libNeoAppleArchive function is not yet
         * public, this can be changed before signing gets
         * released and we have to worry about maintaining API...
         */
        let aarSize = aarData.count
        let aarBuffer = UnsafeMutableRawPointer.allocate(byteCount: aarSize, alignment: MemoryLayout<UInt8>.alignment)
        aarData.copyBytes(to: aarBuffer.assumingMemoryBound(to: UInt8.self), count: aarSize)
        
        var outSize: size_t = 0
        let result = privateKey.withUnsafeBytes { keyPtr in
            authData.withUnsafeBytes { authPtr in
                aarData.withUnsafeBytes { aarPtr in
                    sign_aea_with_private_key_and_auth_data(
                        aarBuffer,
                        aarSize,
                        UnsafeMutableRawPointer(mutating: keyPtr.baseAddress!),
                        privateKey.count,
                        UnsafeMutableRawPointer(mutating: authPtr.baseAddress!),
                        authData.count,
                        &outSize
                    )
                }
            }
        }
        
        guard let resultPtr = result else {
            throw AEAError.signingFailed
        }
        
        return Data(bytes: resultPtr, count: outSize)
    }
    
    static func extractAEA(aeaURL: URL) throws -> Data {
        let aea = neo_aea_with_path(aeaURL.path)
        guard aea != nil else {
            throw AEAError.invalidArchive
        }
        
        let profile = neo_aea_profile(aea!)
        guard profile == 0 else {
            throw AEAError.unsupportedProfile
        }
        
        var outSize: size_t = 0
        let extractedData = neo_aea_extract_data(aea!, &outSize, nil, nil, nil, 0, nil, 0)
        
        guard let extractedData = extractedData else {
            throw AEAError.extractionFailed
        }
        
        return Data(bytes: extractedData, count: outSize)
    }
    
    enum AEAError: Error {
        case invalidKeySize
        case invalidKeyFormat
        case signingFailed
        case invalidArchive
        case unsupportedProfile
        case extractionFailed
    }
}


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
            
            // NOTE: libAppleArchive has a bug where if uncompressionSize == compressionSize, it will not work, I cannot fix this that's on Apple... :P
            
            var compressionType = NEO_AA_COMPRESSION_NONE
            if intent.compression == .lzfse {
                compressionType = NEO_AA_COMPRESSION_LZFSE
            } else if intent.compression == .lzbitmap {
                compressionType = NEO_AA_COMPRESSION_LZBITMAP
            } else if intent.compression == .zlib {
                compressionType = NEO_AA_COMPRESSION_ZLIB
            }
                    
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
    
    // For some reason Xcode **REALLY** doesn't like AARCompressionType and says it doesn't exist but it builds fine
    func resolveCompression(for intent: CreateAARIntent, with completion: @escaping (AARCompressionTypeResolutionResult) -> Void) {
        completion(AARCompressionTypeResolutionResult.success(with: intent.compression))
    }
}
