//
//  AEAProfile0Handler.swift
//  Lina
//
//  Created by Snoolie Keffaber on 2025/05/18.
//

import UIKit
import NeoAppleArchive

class AEAProfile0Handler {
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
