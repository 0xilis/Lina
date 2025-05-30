//
//  CreateArchiveViewController.swift
//  Lina
//
//  Created by Snoolie Keffaber on 2025/05/17.
//

import UIKit
import NeoAppleArchive
import MobileCoreServices
import Foundation

class CreateArchiveViewController: UIViewController, UIDocumentPickerDelegate {
    enum CreationType {
        case aar
        case aea
        case key
        case auth
        case complete
    }
    
    private var currentCreationType: CreationType = .aar
    private var directoryPicker: UIDocumentPickerViewController!
    private var selectedDirectoryURL: URL?
    private let progressView = UIProgressView(progressViewStyle: .bar)
    // MARK: - For AEA
    private var selectedPrivateKeyURL: URL?
    private var selectedAuthDataURL: URL?
    private var currentTempURL: URL?
    
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
        title = "Create Archive"
        
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
        
        let createButton = UIButton(type: .system)
        createButton.setTitle("Create Archive", for: .normal)
        createButton.makePrimaryActionButton()
        createButton.addTarget(self, action: #selector(pressedCreateArchive), for: .touchUpInside)
        
        let createAEAButton = UIButton(type: .system)
        createAEAButton.setTitle("Create Encrypted Archive", for: .normal)
        createAEAButton.makePrimaryActionButton()
        createAEAButton.addTarget(self, action: #selector(pressedCreateAEAArchive), for: .touchUpInside)
        
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.isHidden = true
        
        //stackView.addArrangedSubview(selectButton)
        stackView.addArrangedSubview(createButton)
        stackView.addArrangedSubview(createAEAButton)
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
        directoryPicker = UIDocumentPickerViewController(documentTypes: [kUTTypeFolder as String], in: .open)
        directoryPicker.delegate = self
        directoryPicker.allowsMultipleSelection = false
    }
    
    @objc private func pressedCreateArchive() {
        currentCreationType = .aar
        directoryPicker.delegate = self
        present(directoryPicker, animated: true)
    }
    
    @objc private func pressedCreateAEAArchive() {
        currentCreationType = .aea
        let keyPicker = UIDocumentPickerViewController(documentTypes: [kUTTypeData as String], in: .open)
        keyPicker.delegate = self
        present(keyPicker, animated: true)
    }
    
    private func createArchive() {
        guard let inputURL = selectedDirectoryURL else {
            showAlert(title: "Error", message: "Please select a directory first")
            return
        }
        
        let outputPath = FileManager.default.temporaryDirectory
            .appendingPathComponent("Archive_\(Date().timeIntervalSince1970).aar")
        
        progressView.isHidden = false
        progressView.progress = 0
        
        let securityAccessGranted = inputURL.startAccessingSecurityScopedResource()
        
        guard securityAccessGranted else {
            showAlert(title: "Access Error", message: "Could not access selected files")
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let plainArchive = neo_aa_archive_plain_from_directory(inputURL.path)
            
            neo_aa_archive_plain_compress_write_path(plainArchive, NEO_AA_COMPRESSION_LZFSE, outputPath.path)
            
            // TODO: libNeoAppleArchive currently has a bug in neo_aa_archive_plain_compress_writefd where it will write AAR_MAGIC instead of PBZE_MAGIC... in the future recompile it, but for now just overwrite "AA01" magic with "pbze".
            do {
                let fileHandle = try FileHandle(forWritingTo: outputPath)
                defer { fileHandle.closeFile() }
                let magicBytes: [UInt8] = [0x70, 0x62, 0x7a, 0x65]
                let data = Data(magicBytes)
                fileHandle.seek(toFileOffset: 0)
                fileHandle.write(data)
            } catch {
                print("Failed to overwrite the first four bytes: \(error)")
            }
            
            neo_aa_archive_plain_destroy_nozero(plainArchive)
            
            inputURL.stopAccessingSecurityScopedResource()
            
            DispatchQueue.main.async {
                self.progressView.isHidden = true
                self.showSuccess(outputPath: outputPath)
            }
        }
    }
    
    private func handleKeySelection(_ url: URL) {
        do {
            let keyData = try Data(contentsOf: url)
            guard keyData.count == 97 else {
                showAlert(title: "Invalid Key", message: "Key must be 97 bytes ECDSA-P256 in X9.63 format")
                return
            }
                
            selectedPrivateKeyURL = url
            promptForAuthData()
        } catch {
            showAlert(title: "Error", message: "Could not read key file")
        }
    }
        
    private func promptForAuthData() {
        let authPicker = UIDocumentPickerViewController(documentTypes: [kUTTypeData as String], in: .open)
        authPicker.delegate = self
        present(authPicker, animated: true)
    }
        
    private func createAEAArchive() {
        guard
            let aarURL = selectedDirectoryURL,
            let keyURL = selectedPrivateKeyURL,
            let authURL = selectedAuthDataURL
        else { return }
            
        do {
            let securityAccessGranted = aarURL.startAccessingSecurityScopedResource()
                    && keyURL.startAccessingSecurityScopedResource()
                    && authURL.startAccessingSecurityScopedResource()
            
            guard securityAccessGranted else {
                showAlert(title: "Access Error", message: "Could not access selected files")
                return
            }
            
            let keyData = try Data(contentsOf: keyURL)
            let authData = try Data(contentsOf: authURL)
            let aeaData = try AEAProfile0Handler.createAEAFromAAR(
                aarURL: aarURL,
                privateKey: keyData,
                authData: authData
            )
            
            let tempURL = FileManager.default.temporaryDirectory
                .appendingPathComponent("temp_\(Date().timeIntervalSince1970).aea")
            try aeaData.write(to: tempURL)
            
            self.currentTempURL = tempURL
                
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                let savePicker: UIDocumentPickerViewController
                if #available(iOS 14.0, *) {
                    savePicker = UIDocumentPickerViewController(forExporting: [tempURL])
                } else {
                    savePicker = UIDocumentPickerViewController(url: tempURL, in: .exportToService)
                }
                            
                savePicker.delegate = self
                self.present(savePicker, animated: true) {
                    aarURL.stopAccessingSecurityScopedResource()
                    keyURL.stopAccessingSecurityScopedResource()
                    authURL.stopAccessingSecurityScopedResource()
                }
            }
                
        } catch let error as AEAProfile0Handler.AEAError {
            handleAEAError(error)
        } catch {
            showAlert(title: "Error", message: error.localizedDescription)
        }
        
        print("done with createAEAArchive()")
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
            message = "Unsupported AEA profile"
        case .extractionFailed:
            message = "Failed to extract archive"
        }
        showAlert(title: "Error", message: message)
    }
    
    private func showSuccess(outputPath: URL) {
        let alert = UIAlertController(
            title: "Success!",
            message: "Archive created at \(outputPath.lastPathComponent). Press \"Share\" to save your file.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        alert.addAction(UIAlertAction(title: "Share", style: .default) { _ in
            self.shareFile(url: outputPath)
        })
        
        present(alert, animated: true)
    }
    
    private func shareFile(url: URL) {
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        present(activityVC, animated: true)
    }
    
    // MARK: - Document Picker Delegate
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        if currentCreationType == .aar {
            selectedDirectoryURL = url
            createArchive()
        } else if currentCreationType == .aea {
            selectedDirectoryURL = url
            currentCreationType = .key
            showInstructionAlert(title: "AEA Creation", message: "Select the ECDSA-P256 raw X9.63 private key.") { [weak self] in
                let keyPicker = UIDocumentPickerViewController(documentTypes: [kUTTypeData as String], in: .open)
                keyPicker.delegate = self
                self?.present(keyPicker, animated: true)
            }
        } else if currentCreationType == .key {
            selectedPrivateKeyURL = url
            currentCreationType = .auth
            showInstructionAlert(title: "AEA Creation", message: "Select auth data for the AEA.") {
                let authPicker = UIDocumentPickerViewController(documentTypes: [kUTTypeData as String], in: .open)
                authPicker.delegate = self
                self.present(authPicker, animated: true)
            }
        } else if currentCreationType == .auth {
            selectedAuthDataURL = url
            currentCreationType = .complete
            createAEAArchive()
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        /*if let tempURL = currentTempURL {
            try? FileManager.default.removeItem(at: tempURL)
            currentTempURL = nil
        }*/
        showAlert(title: "Error", message: "Nothing selected.")
    }
    
    private func showInstructionAlert(title: String, message: String, completion: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion()
        })
        present(alert, animated: true)
    }
}

extension UIViewController {
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension UIButton {
    func makePrimaryActionButton() {
        backgroundColor = .systemBlue
        layer.cornerRadius = 12
        layer.shadowOpacity = 0.25
        layer.shadowRadius = 8
        layer.shadowOffset = CGSize(width: 0, height: 4)
        setTitleColor(.white, for: .normal)
        titleLabel?.font = .boldSystemFont(ofSize: 18)
        contentEdgeInsets = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)
        titleLabel?.lineBreakMode = .byWordWrapping
        titleLabel?.numberOfLines = 0
        titleLabel?.textAlignment = .center
    }
}
