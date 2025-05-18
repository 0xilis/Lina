//
//  CreateArchiveViewController.swift
//  Lina
//
//  Created by Snoolie Keffaber on 2025/05/17.
//

import UIKit
import NeoAppleArchive
import MobileCoreServices

class CreateArchiveViewController: UIViewController, UIDocumentPickerDelegate {
    private var directoryPicker: UIDocumentPickerViewController!
    private var selectedDirectoryURL: URL?
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
        
        let selectButton = UIButton(type: .system)
        selectButton.setTitle("Select Directory", for: .normal)
        selectButton.makePrimaryActionButton()
        selectButton.addTarget(self, action: #selector(selectDirectory), for: .touchUpInside)
        
        let createButton = UIButton(type: .system)
        createButton.setTitle("Create Archive", for: .normal)
        createButton.makePrimaryActionButton()
        createButton.addTarget(self, action: #selector(createArchive), for: .touchUpInside)
        
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.isHidden = true
        
        stackView.addArrangedSubview(selectButton)
        stackView.addArrangedSubview(createButton)
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
    }
    
    @objc private func selectDirectory() {
        directoryPicker.delegate = self
        present(directoryPicker, animated: true)
    }
    
    @objc private func createArchive() {
        guard let inputURL = selectedDirectoryURL else {
            showAlert(title: "Error", message: "Please select a directory first")
            return
        }
        
        let outputPath = FileManager.default.temporaryDirectory
            .appendingPathComponent("Archive_\(Date().timeIntervalSince1970).aar")
        
        progressView.isHidden = false
        progressView.progress = 0
        
        DispatchQueue.global(qos: .userInitiated).async {
            // Create plain archive
            let plainArchive = neo_aa_archive_plain_from_directory(inputURL.path)
            
            // Write to path
            neo_aa_archive_plain_write_path(plainArchive, outputPath.path)
            
            // Cleanup
            neo_aa_archive_plain_destroy_nozero(plainArchive)
            
            DispatchQueue.main.async {
                self.progressView.isHidden = true
                self.showSuccess(outputPath: outputPath)
            }
        }
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
        selectedDirectoryURL = url
        title = "Create from: \(url.lastPathComponent)"
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
    }
}
