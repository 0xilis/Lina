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
        extractButton.addTarget(self, action: #selector(extractArchive), for: .touchUpInside)
        
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
    
    @objc private func extractArchive() {
        guard let archiveURL = selectedArchiveURL else {
            showAlert(title: "Error", message: "Please select an archive first")
            return
        }
        
        let outputDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("Extracted_\(Date().timeIntervalSince1970)")
        
        progressView.isHidden = false
        progressView.progress = 0
        
        DispatchQueue.global(qos: .userInitiated).async {
            neo_aa_extract_aar_to_path(archiveURL.path, outputDirectory.path)
            
            DispatchQueue.main.async {
                self.progressView.isHidden = true
                self.showSuccess(outputDirectory: outputDirectory)
            }
        }
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
        title = "Extract: \(url.lastPathComponent)"
    }
}
