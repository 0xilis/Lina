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
import LaunchBoarding

class CreateArchiveViewController: UIViewController, UIDocumentPickerDelegate, LaunchBoardingDelegate {
    
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
    private var selectedCompression: Int32 = NEO_AA_COMPRESSION_LZFSE
    private var iconView: UIImageView!
    private var createButton: UIButton!
    private var createAEAButton: UIButton!
    var onboardingController: LaunchBoardingController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupDocumentPickers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let iconView = self.iconView {
            iconView.tintColor = AppColorSchemeManager.current.color
        }
        
        if let createButton = self.createButton {
            createButton.backgroundColor = AppColorSchemeManager.current.color
        }
        
        if let createAEAButton = self.createAEAButton {
            createAEAButton.backgroundColor = AppColorSchemeManager.current.color
        }
        
        super.viewWillAppear(animated)
    }
    
    private func setupViews() {
        title = trans("Create")
        
        LaunchBoardingHelper.showOnboardingIfNeeded(in: self)
        
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
        if #available (iOS 14, *) {
            iconView.image = UIImage(systemName: "folder.fill.badge.plus") ?? UIImage()
        } else {
            // TODO: The plus is filled in by mistake...
            if let originalImage = UIImage(named: "folder.fill.badge.plus") {
                let tintedImage = originalImage.withRenderingMode(.alwaysTemplate)
                iconView.image = tintedImage
            }
        }
        iconView.tintColor = AppColorSchemeManager.current.color
        iconView.contentMode = .scaleAspectFit
        self.iconView = iconView
        
        let aarLabel = UILabel()
        aarLabel.text = trans("Create .aar archives.")
        aarLabel.font = UIFont.preferredFont(forTextStyle: .callout)
        aarLabel.textAlignment = .center
        if #available(iOS 13.0, *) {
            aarLabel.textColor = .secondaryLabel
        }
        aarLabel.numberOfLines = 1
        aarLabel.adjustsFontSizeToFitWidth = true
        aarLabel.minimumScaleFactor = 0.8
        
        let createButton = UIButton(type: .system)
        createButton.setTitle(trans("Create Archive"), for: .normal)
        createButton.makePrimaryActionButton()
        createButton.addTarget(self, action: #selector(pressedCreateArchive), for: .touchUpInside)
        self.createButton = createButton
        
        let aeaLabel = UILabel()
        aeaLabel.text = trans("Create signed .aea archives.")
        aeaLabel.font = UIFont.preferredFont(forTextStyle: .callout)
        aeaLabel.textAlignment = .center
        if #available(iOS 13.0, *) {
            aeaLabel.textColor = .secondaryLabel
        }
        aeaLabel.numberOfLines = 1
        aeaLabel.adjustsFontSizeToFitWidth = true
        aeaLabel.minimumScaleFactor = 0.8
        
        let createAEAButton = UIButton(type: .system)
        createAEAButton.setTitle(trans("Create Signed Archive"), for: .normal)
        createAEAButton.makePrimaryActionButton()
        createAEAButton.addTarget(self, action: #selector(pressedCreateAEAArchive), for: .touchUpInside)
        createAEAButton.titleLabel?.adjustsFontSizeToFitWidth = true
        createAEAButton.titleLabel?.minimumScaleFactor = 0.8
        createAEAButton.titleLabel?.numberOfLines = 1
        self.createAEAButton = createAEAButton
        
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.isHidden = true
        
        stackView.addArrangedSubview(iconView)
        stackView.addArrangedSubview(aarLabel)
        stackView.addArrangedSubview(createButton)
        stackView.addArrangedSubview(aeaLabel)
        stackView.addArrangedSubview(createAEAButton)
        //TODO: Add a progress handler for NeoAppleArchive
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
        
        DispatchQueue.main.async {
            clearTemporaryDirectory()
        
            let alert = UIAlertController(
                title: trans("Compression Type"),
                message: trans("Select compression method for your archive."),
                preferredStyle: .actionSheet
            )
        
            let compressionOptions: [(title: String, value: Int32)] = [
                (trans("LZFSE (Recommended)"), NEO_AA_COMPRESSION_LZFSE),
                ("ZLIB", NEO_AA_COMPRESSION_ZLIB),
                ("LZBITMAP", NEO_AA_COMPRESSION_LZBITMAP),
                (trans("Raw (Uncompressed)"), NEO_AA_COMPRESSION_NONE)
            ]
        
            for option in compressionOptions {
                alert.addAction(UIAlertAction(title: option.title, style: .default) { _ in
                    self.selectedCompression = option.value
                    self.present(self.directoryPicker, animated: true)
                })
            }
            
            alert.view.tintColor = AppColorSchemeManager.current.color
            
            if let popoverController = alert.popoverPresentationController {
                popoverController.sourceView = self.createButton
                popoverController.sourceRect = self.createButton.bounds
                popoverController.permittedArrowDirections = .any
            }
        
            alert.addAction(UIAlertAction(title: trans("Cancel"), style: .cancel))
        
            self.present(alert, animated: true)
        }
    }
    
    @objc private func pressedCreateAEAArchive() {
        currentCreationType = .aea
        
        clearTemporaryDirectory()
        
        let keyPicker = UIDocumentPickerViewController(documentTypes: [kUTTypeData as String], in: .open)
        keyPicker.delegate = self
        present(keyPicker, animated: true)
    }
    
    private func createArchive() {
        guard let inputURL = selectedDirectoryURL else {
            showAlert(title: trans("Error"), message: trans("Please select a directory first."))
            return
        }
        
        var isDirectory: ObjCBool = false
        if !FileManager.default.fileExists(atPath: inputURL.path, isDirectory: &isDirectory) || !isDirectory.boolValue {
            showAlert(title: trans("Error"), message: trans("The selected path is not a directory."))
            return
        }
        
        let outputPath = FileManager.default.temporaryDirectory
            .appendingPathComponent("Archive_\(Date().timeIntervalSince1970).aar")
        
        progressView.isHidden = false
        progressView.progress = 0
        
        let securityAccessGranted = inputURL.startAccessingSecurityScopedResource()
        
        guard securityAccessGranted else {
            showAlert(title: trans("Error"), message: trans("Could not access selected files."))
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let plainArchive = neo_aa_archive_plain_from_directory(inputURL.path)
            
            neo_aa_archive_plain_compress_write_path(plainArchive, self.selectedCompression, outputPath.path)
            
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
                showAlert(title: trans("Error (Invalid Key)"), message: trans("Private key must be 97 bytes (Raw X9.63 ECDSA-P256)."))
                return
            }
                
            selectedPrivateKeyURL = url
            promptForAuthData()
        } catch {
            showAlert(title: trans("Error"), message: trans("Could not read key file."))
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
                showAlert(title: trans("Error"), message: trans("Could not access selected files."))
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
            showAlert(title: trans("Error"), message: error.localizedDescription)
        }
    }
    
    private func handleAEAError(_ error: AEAProfile0Handler.AEAError) {
        let message: String
        switch error {
        case .invalidKeySize:
            message = trans("Private key must be 97 bytes (Raw X9.63 ECDSA-P256).")
        case .invalidKeyFormat:
            message = trans("Invalid ECDSA-P256 key format (Needs Raw X9.63 ECDSA-P256).")
        case .signingFailed:
            message = trans("Failed to sign archive.")
        case .invalidArchive:
            message = trans("Invalid AAR file.")
        case .unsupportedProfile:
            message = trans("Unsupported AEA profile.")
        case .extractionFailed:
            message = trans("Failed to extract archive.")
        }
        showAlert(title: trans("Error"), message: message)
    }
    
    private func showSuccess(outputPath: URL) {
        let alert = UIAlertController(
            title: trans("Success!"),
            message: "Archive created at \(outputPath.lastPathComponent). Press \"Share\" to save your file.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: trans("OK"), style: .default))
        alert.addAction(UIAlertAction(title: trans("Share"), style: .default) { _ in
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
            showInstructionAlert(title: trans("AEA Creation"), message: trans("Select the ECDSA-P256 raw X9.63 private key.")) { [weak self] in
                let keyPicker = UIDocumentPickerViewController(documentTypes: [kUTTypeData as String], in: .open)
                keyPicker.delegate = self
                self?.present(keyPicker, animated: true)
            }
        } else if currentCreationType == .key {
            selectedPrivateKeyURL = url
            currentCreationType = .auth
            showInstructionAlert(title: trans("AEA Creation"), message: trans("Select auth data for the AEA.")) {
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
        showAlert(title: trans("Error"), message: trans("Nothing selected."))
    }
    
    func onboardingDidFinish() {
        // finished with launchboarding
        LaunchBoardingHelper.completeOnboarding()
        onboardingController.dismiss(animated: true)
    }
    
    func onboardingDidSkip() {
        // skipped (no way this can normally happen)
        onboardingController.dismiss(animated: true)
    }
    
    private func showInstructionAlert(title: String, message: String, completion: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: trans("OK"), style: .default) { _ in
            completion()
        })
        present(alert, animated: true)
    }
}

extension UIViewController {
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: trans("OK"), style: .default))
        alert.view.tintColor = AppColorSchemeManager.current.color
        present(alert, animated: true)
    }
}

extension UIButton {
    func makePrimaryActionButton() {
        backgroundColor = AppColorSchemeManager.current.color
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
