//
//  CreditsViewController.swift
//  Lina - Made with ♡ By Snoolie
//
//  Created by Snoolie Keffaber on 2025/05/17.
//

import UIKit

class CreditsViewController: UIViewController {
    let githubURLs: [String: String] = [
            "0xilis": "https://github.com/0xilis",
            "justtryingthingsout": "https://github.com/justtryingthingsout",
            "AdelaideSky": "https://github.com/AdelaideSky"
        ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addDebugOptions()
    }
    
    private func setupUI() {
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemGroupedBackground
        } else {
            // Fallback on earlier versions
        }
        title = "Credits"
        
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
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let firstUserView = createUserCard(
            imageName: "snoolie_pfp_Lina",
            name: "0xilis",
            role: "Main Developer"
        )
        addTapGesture(to: firstUserView, with: "0xilis")
        
        let secondUserView = createUserCard(
            imageName: "plx_pfp_Lina",
            name: "justtryingthingsout",
            role: "Core Contributor"
        )
        addTapGesture(to: secondUserView, with: "justtryingthingsout")
        
        let thirdUserView = createUserCard(
            imageName: "ade_pfp_Lina",
            name: "AdelaideSky",
            role: "Miscellaneous"
        )
        addTapGesture(to: thirdUserView, with: "AdelaideSky")
        
        stackView.addArrangedSubview(firstUserView)
        stackView.addArrangedSubview(secondUserView)
        stackView.addArrangedSubview(thirdUserView)
        
        container.addSubview(stackView)
        view.addSubview(container)
        
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            container.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            stackView.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -20)
        ])
    }
    
    private func addDebugOptions() {
        #if DEBUG || TESTFLIGHT
        let resetItem = UIBarButtonItem(
            title: "Reset Onboarding",
            style: .plain,
            target: self,
            action: #selector(resetOnboarding)
        )
            
        navigationItem.rightBarButtonItems = [resetItem]
        #endif
    }
    
    private func createUserCard(imageName: String, name: String, role: String) -> UIView {
        let card = UIView()
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 25
        imageView.clipsToBounds = true
        
        let nameLabel = UILabel()
        nameLabel.font = .boldSystemFont(ofSize: 18)
        nameLabel.text = name
        
        let roleLabel = UILabel()
        roleLabel.font = .systemFont(ofSize: 14)
        if #available(iOS 13.0, *) {
            roleLabel.textColor = .secondaryLabel
        } else {
            // TODO: Fallback on earlier versions
        }
        roleLabel.text = role
        
        let textStack = UIStackView(arrangedSubviews: [nameLabel, roleLabel])
        textStack.axis = .vertical
        textStack.spacing = 4
        
        let horizontalStack = UIStackView(arrangedSubviews: [imageView, textStack])
        horizontalStack.spacing = 16
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.image = UIImage(named: imageName)
        
        card.addSubview(horizontalStack)
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 50),
            imageView.heightAnchor.constraint(equalToConstant: 50),
            
            horizontalStack.topAnchor.constraint(equalTo: card.topAnchor),
            horizontalStack.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            horizontalStack.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            horizontalStack.bottomAnchor.constraint(equalTo: card.bottomAnchor)
        ])
        
        return card
    }
    
    private func addTapGesture(to view: UIView, with username: String) {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleCardTap(_:)))
        view.addGestureRecognizer(tapGesture)
        view.isUserInteractionEnabled = true
        view.accessibilityIdentifier = username
    }
    
    @objc private func handleCardTap(_ sender: UITapGestureRecognizer) {
        guard let tappedView = sender.view,
            let username = tappedView.accessibilityIdentifier,
            let urlString = githubURLs[username],
            let url = URL(string: urlString) else {
            return
        }
        UIApplication.shared.open(url)
    }
    
    #if DEBUG || TESTFLIGHT
    @objc private func resetOnboarding() {
        UIOnboardingHelper.resetOnboarding()
        showAlert(title: "Onboarding Reset", message: "Will show on next launch")
    }
    #endif
}
