//
//  ExtractArchiveViewController.swift
//  Lina
//
//  Created by Snoolie Keffaber on 2025/05/17.
//

import UIKit
import NeoAppleArchive
import UniformTypeIdentifiers

class ExtractArchiveViewController: UIViewController {
    let archivePicker = UIDocumentPickerViewController(forOpeningContentTypes: [.data])
    var selectedArchiveURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        // UI setup code with input fields for decryption parameters
        let extractButton = UIButton(type: .system)
        extractButton.setTitle("Extract Archive", for: .normal)
        extractButton.addTarget(self, action: #selector(extractArchive), for: .touchUpInside)
    }
    
    @objc private func extractArchive() {
        print("Implement .aar extraction later")
    }
    
    @objc private func extractEncryptedArchive() {
        guard let archivePath = selectedArchiveURL?.path else { return }
        
        DispatchQueue.global(qos: .userInitiated).async {
            print("Implement .aea decryption later")
        }
    }
    
    private func handleExtractedData(_ data: Data) {
        // Handle extracted data (save to file system, etc.)
    }
}

extension ExtractArchiveViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        selectedArchiveURL = url
    }
}
