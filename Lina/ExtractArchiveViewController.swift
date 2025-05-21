//
//  ExtractArchiveViewController.swift
//  Lina
//
//  Created by Snoolie Keffaber on 2025/05/17.
//

import UIKit
import NeoAppleArchive
import MobileCoreServices

class ExtractArchiveViewController: UIViewController, UIDocumentPickerDelegate {
    private var archivePicker: UIDocumentPickerViewController!
    private var selectedArchiveURL: URL?
    private let progressView = UIProgressView(progressViewStyle: .bar)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupDocumentPickers()
    }
    
    private func setupViews() {
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemGroupedBackground
        } else {
            // Fallback on earlier versions
        }
        title = "Extract Archive"
        
        let container = UIView()
        if #available(iOS 13.0, *) {
            container.backgroundColor = .secondarySystemGroupedBackground
        } else {
            // Fallback on earlier versions
        }
        container.layer.cornerRadius = 16
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let extractButton = UIButton(type: .system)
        extractButton.setTitle("Extract Archive", for: .normal)
        extractButton.makePrimaryActionButton()
        extractButton.addTarget(self, action: #selector(pressedExtractArchive), for: .touchUpInside)
        
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.isHidden = true
        
        stackView.addArrangedSubview(extractButton)
        stackView.addArrangedSubview(progressView)
        
        container.addSubview(stackView)
        view.addSubview(container)
        
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            container.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            stackView.topAnchor.constraint(equalTo: container.topAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -24),
            stackView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -24),
            
            progressView.heightAnchor.constraint(equalToConstant: 4)
        ])
    }
    
    private func setupDocumentPickers() {
        archivePicker = UIDocumentPickerViewController(documentTypes: [kUTTypeArchive as String], in: .open)
        archivePicker.delegate = self
    }
    
    @objc private func pressedExtractArchive() {
        let keyPicker = UIDocumentPickerViewController(documentTypes: [kUTTypeData as String], in: .open)
        keyPicker.delegate = self
        present(keyPicker, animated: true)
    }
    
    private func extractArchive() {
        guard let archiveURL = selectedArchiveURL else {
            showAlert(title: "Error", message: "Please select an archive first")
            return
        }
        
        let outputDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("Extracted_\(Date().timeIntervalSince1970)")
        
        progressView.isHidden = false
        progressView.progress = 0
        
        _ = archiveURL.startAccessingSecurityScopedResource()
        
        /*
         * TODO: Basing off file type by path extension is BAD!
         * In the future, use the magic of the file to determine aea / aar
         */
        let pathExtension = archiveURL.pathExtension
        if pathExtension == "aea" || pathExtension == "shortcut" {
            do {
                let extractedData = try AEAProfile0Handler.extractAEA(aeaURL: archiveURL)
                let outputPath = FileManager.default.temporaryDirectory
                .appendingPathComponent("Extracted_\(Date().timeIntervalSince1970)")
                        
                try extractedData.write(to: outputPath)
                showSuccess(outputDirectory: outputPath)
            } catch let error as AEAProfile0Handler.AEAError {
                handleAEAError(error)
            } catch {
                self.showAlert(title: "Error", message: error.localizedDescription)
            }
        } else if pathExtension == "aar" || pathExtension == "yaa" {
            DispatchQueue.global(qos: .userInitiated).async {
                neo_aa_extract_aar_to_path(archiveURL.path, outputDirectory.path)
                
                DispatchQueue.main.async {
                    self.progressView.isHidden = true
                    self.showSuccess(outputDirectory: outputDirectory)
                }
            }
        } else {
            self.progressView.isHidden = true
            showAlert(title: "Error", message: "File is not AEA or AAR!")
        }
        
        archiveURL.stopAccessingSecurityScopedResource()
    }
    
    private func handleAEAError(_ error: AEAProfile0Handler.AEAError) {
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
        showAlert(title: "Error", message: message)
    }
    
    private func showSuccess(outputDirectory: URL) {
        let alert = UIAlertController(
            title: "Extraction Complete!",
            message: "Files extracted to \(outputDirectory.lastPathComponent)",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        alert.addAction(UIAlertAction(title: "View Files", style: .default) { _ in
            self.presentFileBrowser(at: outputDirectory)
        })
        
        present(alert, animated: true)
    }
    
    private func presentFileBrowser(at url: URL) {
        if #available(iOS 14.0, *) {
            let documentPicker = UIDocumentPickerViewController(forExporting: [url])
            present(documentPicker, animated: true)
        } else {
            let documentPicker = UIDocumentPickerViewController(url: url, in: .exportToService)
            present(documentPicker, animated: true)
        }
    }
    
    // MARK: - Document Picker Delegate
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        selectedArchiveURL = url
        extractArchive()
    }
}
