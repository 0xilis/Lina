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
    var fileURLFromShare: URL?
    private var iconView: UIImageView!
    private var extractButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupDocumentPickers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let iconView = self.iconView {
            iconView.tintColor = AppColorSchemeManager.current.color
        }
        
        if let extractButton = self.extractButton {
            extractButton.backgroundColor = AppColorSchemeManager.current.color
        }
        
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if fileURLFromShare != nil {
            selectedArchiveURL = fileURLFromShare
            fileURLFromShare = nil
            extractArchive()
        }
    }
    
    private func setupViews() {
        title = "Extract"
        
        let container = UIView()
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemGroupedBackground
            container.backgroundColor = .secondarySystemGroupedBackground
        } else {
            view.backgroundColor = .white
            container.backgroundColor = UIColor(red: (240 / 256), green: (240 / 256), blue: (240 / 256), alpha: 1)
        }
        container.layer.cornerRadius = 16
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let iconView = UIImageView()
        iconView.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13, *) {
            iconView.image = UIImage(systemName: "archivebox.fill") ?? UIImage()
        } else {
            if let originalImage = UIImage(named: "archivebox.fill") {
                let tintedImage = originalImage.withRenderingMode(.alwaysTemplate)
                iconView.image = tintedImage
            }
        }
        iconView.tintColor = AppColorSchemeManager.current.color
        iconView.contentMode = .scaleAspectFit
        self.iconView = iconView
        
        let infoLabel = UILabel()
        infoLabel.text = "Extract .aea, .aar, and .yaa files."
        infoLabel.textAlignment = .center
        infoLabel.numberOfLines = 0
        if #available(iOS 13.0, *) {
            infoLabel.textColor = .secondaryLabel
        }
        infoLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        
        let extractButton = UIButton(type: .system)
        extractButton.setTitle("Extract Archive", for: .normal)
        extractButton.makePrimaryActionButton()
        extractButton.addTarget(self, action: #selector(pressedExtractArchive), for: .touchUpInside)
        self.extractButton = extractButton
        
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.isHidden = true
        
        stackView.addArrangedSubview(iconView)
        stackView.addArrangedSubview(infoLabel)
        stackView.addArrangedSubview(extractButton)
        //TODO: Implement progress handler support into NeoAppleArchive
        //stackView.addArrangedSubview(progressView)
        
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
            
            iconView.heightAnchor.constraint(equalToConstant: 60),
            iconView.widthAnchor.constraint(equalToConstant: 60),
            
            progressView.heightAnchor.constraint(equalToConstant: 4),
            
            extractButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
        ])
    }
    
    private func setupDocumentPickers() {
        archivePicker = UIDocumentPickerViewController(documentTypes: [
            "com.apple.archive",
            "com.apple.encrypted-archive"
        ], in: .open)
        archivePicker.delegate = self
    }
    
    @objc private func pressedExtractArchive() {
        clearTemporaryDirectory()
        let keyPicker = UIDocumentPickerViewController(documentTypes: [kUTTypeData as String], in: .open)
        keyPicker.delegate = self
        present(keyPicker, animated: true)
    }
    
    private func extractArchive() {
        guard let archiveURL = selectedArchiveURL else {
            showAlert(title: "Error", message: "Please select an archive first.")
            return
        }
        
        let outputDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        
        progressView.isHidden = false
        progressView.progress = 0
        
        let securityAccessGranted = archiveURL.startAccessingSecurityScopedResource()
        
        guard securityAccessGranted else {
            showAlert(title: "Access Error", message: "Could not access selected files.")
            return
        }
        
        /*
         * TODO: Basing off file type by path extension is BAD!
         * In the future, use the magic of the file to determine aea / aar
         */
        let pathExtension = archiveURL.pathExtension
        if pathExtension == "aea" || pathExtension == "shortcut" {
            do {
                let extractedData = try AEAProfile0Handler.extractAEA(aeaURL: archiveURL)
                // Assume AEA output is AAR even though thats not always the case...
                let outputPath = FileManager.default.temporaryDirectory
                .appendingPathComponent("Extracted.aar")
                        
                try extractedData.write(to: outputPath)
                showSuccess(outputDirectory: outputPath)
            } catch let error as AEAProfile0Handler.AEAError {
                handleAEAError(error)
            } catch {
                self.showAlert(title: "Error", message: error.localizedDescription)
            }
        } else if pathExtension == "aar" || pathExtension == "yaa" {
                
            do {
                try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)
            } catch {
                archiveURL.stopAccessingSecurityScopedResource()
                self.progressView.isHidden = true
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: "Failed to create directory at \(outputDirectory)")
                    return
                }
                return
            }
                
            let isReadable = FileManager.default.isReadableFile(atPath: archiveURL.path)
            if (isReadable == false) {
                archiveURL.stopAccessingSecurityScopedResource()
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: "archiveURL.path is not readable (\(archiveURL.path)).")
                    return
                }
                return
            }
                
            let (errorCode, stderrOutput) = captureStderrOutput {
                neo_aa_extract_aar_to_path_err(archiveURL.path, outputDirectory.path)
            }
                
            if (errorCode == 0) {
                DispatchQueue.main.async {
                    self.progressView.isHidden = true
                    self.showSuccess(outputDirectory: outputDirectory)
                }
            } else {
                DispatchQueue.main.async {
                    self.progressView.isHidden = true
                    let errorMessage = "neo_aa_extract_aar_to_path_err returned code: \(errorCode)." +
                                    (stderrOutput.map { " Stderr: \($0)" } ?? "")
                    self.showAlert(title: "Error", message: errorMessage)
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
            message = "Private key must be 97 bytes (Raw X9.63 ECDSA-P256)."
        case .invalidKeyFormat:
            message = "Invalid ECDSA-P256 key format (Needs Raw X9.63 ECDSA-P256)."
        case .signingFailed:
            message = "Failed to sign archive."
        case .invalidArchive:
            message = "Invalid AAR file."
        case .unsupportedProfile:
            message = "Unsupported AEA profile (Currently only AEAProfile 0 is supported)."
        case .extractionFailed:
            message = "Failed to extract archive."
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
