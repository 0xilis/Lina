//
//  CreateArchiveViewController.swift
//  Lina
//
//  Created by Snoolie Keffaber on 2025/05/17.
//

import UIKit
import NeoAppleArchive
import UniformTypeIdentifiers

class CreateArchiveViewController: UIViewController, UIDocumentPickerDelegate {
    let directoryPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.folder])
    var selectedDirectoryURL: URL?
    let passwordField = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        let selectButton = UIButton(type: .system)
        selectButton.setTitle("Select Directory", for: .normal)
        selectButton.addTarget(self, action: #selector(selectDirectory), for: .touchUpInside)
        
        let createButton = UIButton(type: .system)
        createButton.setTitle("Create Archive", for: .normal)
        createButton.addTarget(self, action: #selector(createArchive), for: .touchUpInside)
    }
    
    @objc private func selectDirectory() {
        directoryPicker.delegate = self
        present(directoryPicker, animated: true)
    }
    
    @objc private func createArchive() {
        guard let dirPath = selectedDirectoryURL?.path else { return }
        
        DispatchQueue.global(qos: .userInitiated).async {
            // Create plain archive
            let plainArchive = neo_aa_archive_plain_from_directory(dirPath)
            
            // TODO: Implement later creating plain apple archives
            
            DispatchQueue.main.async {
                self.showAlert(title: "Success", message: "Archive created successfully")
            }
        }
    }
}

extension UIViewController {
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
