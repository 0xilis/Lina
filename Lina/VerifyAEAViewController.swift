//
//  VerifyAEAViewController.swift
//  Lina
//
//  Created by Snoolie Keffaber on 2025/06/02.
//

import UIKit
import NeoAppleArchive
import MobileCoreServices

class VerifyAEAViewController: UIViewController, UIDocumentPickerDelegate {
    private var aeaPicker: UIDocumentPickerViewController!
    private var keyPicker: UIDocumentPickerViewController!
    private var selectedAEAURL: URL?
    private var selectedKeyURL: URL?
    private var iconView: UIImageView!
    private var verifyButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupDocumentPickers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let iconView = self.iconView {
            iconView.tintColor = AppColorSchemeManager.current.color
        }
        
        if let verifyButton = self.verifyButton {
            verifyButton.backgroundColor = AppColorSchemeManager.current.color
        }
        
        super.viewWillAppear(animated)
    }
    
    private func setupViews() {
        title = trans("Verify")
        
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
        if let originalImage = UIImage(named: "checkmark.shield.fill") {
            let tintedImage = originalImage.withRenderingMode(.alwaysTemplate)
            iconView.image = tintedImage
        }
        iconView.tintColor = AppColorSchemeManager.current.color
        iconView.contentMode = .scaleAspectFit
        self.iconView = iconView
        
        let infoLabel = UILabel()
        infoLabel.text = trans("Verify the signature of .aea files using ECDSA-P256 public keys.")
        infoLabel.textAlignment = .center
        infoLabel.numberOfLines = 0
        if #available(iOS 13.0, *) {
            infoLabel.textColor = .secondaryLabel
        }
        infoLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        
        let verifyButton = UIButton(type: .system)
        verifyButton.setTitle(trans("Verify AEA"), for: .normal)
        verifyButton.makePrimaryActionButton()
        verifyButton.addTarget(self, action: #selector(pressedVerifyAEA), for: .touchUpInside)
        self.verifyButton = verifyButton
        
        stackView.addArrangedSubview(iconView)
        stackView.addArrangedSubview(infoLabel)
        stackView.addArrangedSubview(verifyButton)
        
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
            
            verifyButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
        ])
    }
    
    private func setupDocumentPickers() {
        aeaPicker = UIDocumentPickerViewController(documentTypes: [
            "com.apple.encrypted-archive"
        ], in: .open)
        aeaPicker.delegate = self
        
        keyPicker = UIDocumentPickerViewController(documentTypes: [kUTTypeData as String], in: .open)
        keyPicker.delegate = self
    }
    
    @objc private func pressedVerifyAEA() {
        present(aeaPicker, animated: true)
    }
    
    private func verifyAEA() {
        guard let aeaURL = selectedAEAURL else {
            showAlert(title: trans("Error"), message: trans("Please select an AEA file first."))
            return
        }
        
        guard let keyURL = selectedKeyURL else {
            showAlert(title: trans("Error"), message: trans("Please select a public key file."))
            return
        }
        
        let securityAccessGranted = aeaURL.startAccessingSecurityScopedResource()
        let keyAccessGranted = keyURL.startAccessingSecurityScopedResource()
        
        defer {
            if securityAccessGranted { aeaURL.stopAccessingSecurityScopedResource() }
            if keyAccessGranted { keyURL.stopAccessingSecurityScopedResource() }
        }
        
        do {
            let keyData = try Data(contentsOf: keyURL)
            guard keyData.count == 65, keyData.first == 0x04 else {
                showAlert(title: trans("Error (Invalid Key)"), message: trans("Public key must be 65 bytes starting with 0x04 (Raw X9.63 ECDSA-P256)."))
                return
            }
            
            let aea = neo_aea_with_path(aeaURL.path)
            guard aea != nil else {
                showAlert(title: trans("Error"), message: trans("Could not open AEA file."))
                return
            }
            
            let verificationResult = keyData.withUnsafeBytes { keyPtr in
                neo_aea_verify(aea, UnsafeMutableRawPointer(mutating: keyPtr.baseAddress!.assumingMemoryBound(to: UInt8.self)))
            }
            
            if verificationResult == 0 {
                showAlert(title: trans("Verification Successful"), message: trans("The AEA file is authentic and valid."), isSuccess: true)
            } else {
                showAlert(title: trans("Verification Failed"), message: trans("The signature is invalid or the file has been tampered with."))
            }
        } catch {
            showAlert(title: trans("Error"), message: error.localizedDescription)
        }
    }
    
    private func showAlert(title: String, message: String, isSuccess: Bool = false) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        alert.view.tintColor = AppColorSchemeManager.current.color
        present(alert, animated: true)
    }
    
    // MARK: - Document Picker Delegate
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        
        if controller == aeaPicker {
            selectedAEAURL = url
            present(keyPicker, animated: true)
        } else if controller == keyPicker {
            selectedKeyURL = url
            verifyAEA()
        }
    }
}
