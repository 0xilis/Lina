//
//  CreditsViewController.swift
//  Lina - Made with ♡ By Snoolie
//
//  Created by Snoolie Keffaber on 2025/05/17.
//

import UIKit
import SwiftUI

class CreditsViewController: UIViewController {
    
    private let sourceCodeURL = URL(string: "https://github.com/0xilis/Lina")!
    private let githubURLs: [String: String] = [
        "0xilis": "https://github.com/0xilis",
        "justtryingthingsout": "https://github.com/justtryingthingsout",
        "AdelaideSky": "https://github.com/AdelaideSky"
    ]
    
    private var selectedColorScheme: AppColorSchemeManager.ColorScheme = .systemBlue {
        didSet {
            updateColorScheme()
            AppColorSchemeManager.setCurrentScheme(selectedColorScheme)
        }
    }
    
    private var colorSchemeButtons: [UIButton] = []
    private var scrollView: UIScrollView!
    #if DEBUG || TESTFLIGHT
    private var resetOnboardingButton: UIButton!
    #endif
    private var sourceCodeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectedColorScheme = AppColorSchemeManager.current
        
        setupUI()
        updateColorScheme()
    }
    
    private func setupUI() {
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemGroupedBackground
        } else {
            view.backgroundColor = .white
        }
        title = trans("Credits")
        
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        let mainStackView = UIStackView()
        mainStackView.axis = .vertical
        mainStackView.spacing = 24
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(mainStackView)
        
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
        
        let appInfoCard = createCard()
        let appInfoStack = UIStackView()
        appInfoStack.axis = .vertical
        appInfoStack.spacing = 16
        appInfoStack.alignment = .center
        
        let appIcon = UIImageView()
        appIcon.image = UIImage(named: "LinaIcon") ?? UIImage()
        appIcon.contentMode = .scaleAspectFit
        appIcon.layer.cornerRadius = 16
        appIcon.clipsToBounds = true
        NSLayoutConstraint.activate([
            appIcon.widthAnchor.constraint(equalToConstant: 80),
            appIcon.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        let appNameLabel = UILabel()
        appNameLabel.text = "Lina"
        appNameLabel.font = .systemFont(ofSize: 24, weight: .bold)
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            let versionLabel = UILabel()
            versionLabel.text = "Version \(version)"
            if #available(iOS 13.0, *) {
                versionLabel.textColor = .secondaryLabel
            }
            versionLabel.font = .systemFont(ofSize: 16, weight: .regular)
            appInfoStack.addArrangedSubview(versionLabel)
        }
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = trans("Create and extract AAR/AEA archives using libNeoAppleArchive. Sign and verify archives with ECDSA-P256 keys.")
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
        descriptionLabel.font = .preferredFont(forTextStyle: .body)
        
        appInfoStack.addArrangedSubview(appIcon)
        appInfoStack.addArrangedSubview(appNameLabel)
        appInfoStack.addArrangedSubview(descriptionLabel)
        
        appInfoCard.addSubview(appInfoStack)
        appInfoStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            appInfoStack.topAnchor.constraint(equalTo: appInfoCard.topAnchor, constant: 20),
            appInfoStack.leadingAnchor.constraint(equalTo: appInfoCard.leadingAnchor, constant: 20),
            appInfoStack.trailingAnchor.constraint(equalTo: appInfoCard.trailingAnchor, constant: -20),
            appInfoStack.bottomAnchor.constraint(equalTo: appInfoCard.bottomAnchor, constant: -20)
        ])
        
        let sourceCodeCard = createCard()
        let sourceCodeButton = UIButton(type: .system)
        sourceCodeButton.setTitle(trans("View Source Code"), for: .normal)
        sourceCodeButton.addTarget(self, action: #selector(openSourceCode), for: .touchUpInside)
        sourceCodeButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        sourceCodeButton.translatesAutoresizingMaskIntoConstraints = false
        sourceCodeButton.makePrimaryActionButton()
        NSLayoutConstraint.activate([
            sourceCodeButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        let sourceCodeButtonLabel = sourceCodeButton.titleLabel!
        sourceCodeButtonLabel.numberOfLines = 1
        sourceCodeButtonLabel.adjustsFontSizeToFitWidth = true
        sourceCodeButtonLabel.minimumScaleFactor = 0.8
        self.sourceCodeButton = sourceCodeButton
        sourceCodeCard.addSubview(sourceCodeButton)
        
        NSLayoutConstraint.activate([
            sourceCodeButton.topAnchor.constraint(equalTo: sourceCodeCard.topAnchor, constant: 15),
            sourceCodeButton.leadingAnchor.constraint(equalTo: sourceCodeCard.leadingAnchor, constant: 20),
            sourceCodeButton.trailingAnchor.constraint(equalTo: sourceCodeCard.trailingAnchor, constant: -20),
            sourceCodeButton.bottomAnchor.constraint(equalTo: sourceCodeCard.bottomAnchor, constant: -15),
            sourceCodeButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        let colorSchemeCard = createCard()
        let colorSchemeStack = UIStackView()
        colorSchemeStack.axis = .vertical
        colorSchemeStack.spacing = 16
        
        let colorSchemeTitle = UILabel()
        colorSchemeTitle.text = trans("App Color Scheme")
        colorSchemeTitle.font = .systemFont(ofSize: 18, weight: .semibold)
        
        let buttonContainer = UIView()
        let buttonStack = UIStackView()
        buttonStack.axis = .horizontal
        buttonStack.distribution = .fillEqually
        buttonStack.spacing = 12
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        
        for scheme in AppColorSchemeManager.ColorScheme.allCases {
            let button = UIButton()
            button.backgroundColor = scheme.color
            button.layer.cornerRadius = 8
            button.tag = scheme.hashValue
            button.addTarget(self, action: #selector(colorSchemeSelected(_:)), for: .touchUpInside)
            
            if scheme == selectedColorScheme {
                if #available(iOS 13.0, *) {
                    button.setImage(UIImage(systemName: "checkmark"), for: .normal)
                } else {
                    // TODO: Checkmark appears too big...
                    let checkmark = UIImage(named: "checkmark") ?? UIImage()
                    button.setImage(checkmark.withRenderingMode(.alwaysTemplate).tabBarIcon(), for: .normal)
                }
                button.tintColor = .white
            }
            
            colorSchemeButtons.append(button)
            buttonStack.addArrangedSubview(button)
        }
        
        buttonContainer.addSubview(buttonStack)
        NSLayoutConstraint.activate([
            buttonStack.topAnchor.constraint(equalTo: buttonContainer.topAnchor),
            buttonStack.leadingAnchor.constraint(equalTo: buttonContainer.leadingAnchor),
            buttonStack.trailingAnchor.constraint(equalTo: buttonContainer.trailingAnchor),
            buttonStack.bottomAnchor.constraint(equalTo: buttonContainer.bottomAnchor),
            buttonStack.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        colorSchemeStack.addArrangedSubview(colorSchemeTitle)
        colorSchemeStack.addArrangedSubview(buttonContainer)
        
        colorSchemeCard.addSubview(colorSchemeStack)
        colorSchemeStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            colorSchemeStack.topAnchor.constraint(equalTo: colorSchemeCard.topAnchor, constant: 20),
            colorSchemeStack.leadingAnchor.constraint(equalTo: colorSchemeCard.leadingAnchor, constant: 20),
            colorSchemeStack.trailingAnchor.constraint(equalTo: colorSchemeCard.trailingAnchor, constant: -20),
            colorSchemeStack.bottomAnchor.constraint(equalTo: colorSchemeCard.bottomAnchor, constant: -20)
        ])
        
        let creditsCard = createCard()
        let creditsStack = UIStackView()
        creditsStack.axis = .vertical
        creditsStack.spacing = 20
        
        let creditsTitle = UILabel()
        creditsTitle.text = trans("Credits")
        creditsTitle.font = .systemFont(ofSize: 18, weight: .semibold)
        creditsStack.addArrangedSubview(creditsTitle)
        
        let usersStack = UIStackView()
        usersStack.axis = .vertical
        usersStack.spacing = 16
        
        let firstUserView = createUserCard(
            imageName: "snoolie_pfp_Lina",
            name: "0xilis",
            role: trans("Main Developer")
        )
        addTapGesture(to: firstUserView, with: "0xilis")
        usersStack.addArrangedSubview(firstUserView)
        
        let secondUserView = createUserCard(
            imageName: "plx_pfp_Lina",
            name: "justtryingthingsout",
            role: trans("Core Contributor")
        )
        addTapGesture(to: secondUserView, with: "justtryingthingsout")
        usersStack.addArrangedSubview(secondUserView)
        
        let thirdUserView = createUserCard(
            imageName: "ade_pfp_Lina",
            name: "AdelaideSky",
            role: trans("Miscellaneous")
        )
        addTapGesture(to: thirdUserView, with: "AdelaideSky")
        usersStack.addArrangedSubview(thirdUserView)
        
        creditsStack.addArrangedSubview(usersStack)
        
        let thanksLabel = UILabel()
        thanksLabel.text = trans("...and thanks to users like you!")
        thanksLabel.font = .systemFont(ofSize: 14, weight: .regular)
        thanksLabel.textAlignment = .center
        if #available(iOS 13.0, *) {
            thanksLabel.textColor = .secondaryLabel
        }
        creditsStack.addArrangedSubview(thanksLabel)
        
        creditsCard.addSubview(creditsStack)
        creditsStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            creditsStack.topAnchor.constraint(equalTo: creditsCard.topAnchor, constant: 20),
            creditsStack.leadingAnchor.constraint(equalTo: creditsCard.leadingAnchor, constant: 20),
            creditsStack.trailingAnchor.constraint(equalTo: creditsCard.trailingAnchor, constant: -20),
            creditsStack.bottomAnchor.constraint(equalTo: creditsCard.bottomAnchor, constant: -20)
        ])
        
        #if DEBUG || TESTFLIGHT
        let resetCard = createCard()
        let resetButton = UIButton(type: .system)
        resetButton.setTitle(trans("Reset Onboarding"), for: .normal)
        resetButton.makePrimaryActionButton()
        resetButton.addTarget(self, action: #selector(resetOnboarding), for: .touchUpInside)
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        resetCard.addSubview(resetButton)
        self.resetOnboardingButton = resetButton
        
        NSLayoutConstraint.activate([
            resetButton.topAnchor.constraint(equalTo: resetCard.topAnchor, constant: 15),
            resetButton.leadingAnchor.constraint(equalTo: resetCard.leadingAnchor, constant: 20),
            resetButton.trailingAnchor.constraint(equalTo: resetCard.trailingAnchor, constant: -20),
            resetButton.bottomAnchor.constraint(equalTo: resetCard.bottomAnchor, constant: -15),
            resetButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        #endif
        
        mainStackView.addArrangedSubview(appInfoCard)
        mainStackView.addArrangedSubview(sourceCodeCard)
        mainStackView.addArrangedSubview(colorSchemeCard)
        mainStackView.addArrangedSubview(creditsCard)
        #if DEBUG || TESTFLIGHT
        mainStackView.addArrangedSubview(resetCard)
        #endif
    }
    
    private func createCard() -> UIView {
        let card = UIView()
        if #available(iOS 13.0, *) {
            card.backgroundColor = .secondarySystemGroupedBackground
        } else {
            card.backgroundColor = UIColor(red: (240 / 256), green: (240 / 256), blue: (240 / 256), alpha: 1)
        }
        card.layer.cornerRadius = 16
        return card
    }
    
    private func updateColorScheme() {
        UIView.animate(withDuration: 0.3) {
            let selectedColorScheme = self.selectedColorScheme
            self.view.tintColor = selectedColorScheme.color
            #if DEBUG || TESTFLIGHT
            if let resetOnboardingButton = self.resetOnboardingButton {
                resetOnboardingButton.backgroundColor = selectedColorScheme.color
            }
            #endif
            if let sourceCodeButton = self.sourceCodeButton {
                sourceCodeButton.backgroundColor = selectedColorScheme.color
            }
            
            for button in self.colorSchemeButtons {
                if button.tag == selectedColorScheme.hashValue {
                    if #available(iOS 13.0, *) {
                        button.setImage(UIImage(systemName: "checkmark"), for: .normal)
                    } else {
                        // TODO: Checkmark appears too big...
                        let checkmark = UIImage(named: "checkmark") ?? UIImage()
                        button.setImage(checkmark.withRenderingMode(.alwaysTemplate).tabBarIcon(), for: .normal)
                    }
                    button.tintColor = .white
                } else {
                    button.setImage(nil, for: .normal)
                }
            }
        }
        
        if let tabBar = tabBarController?.tabBar {
            tabBar.tintColor = selectedColorScheme.color
        }
        
        navigationController?.navigationBar.tintColor = selectedColorScheme.color
    }
    
    private func createUserCard(imageName: String, name: String, role: String) -> UIView {
        let card = UIView()
        card.isUserInteractionEnabled = true
        
        let horizontalStack = UIStackView()
        horizontalStack.axis = .horizontal
        horizontalStack.spacing = 16
        horizontalStack.alignment = .center
        horizontalStack.translatesAutoresizingMaskIntoConstraints = false
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 25
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: imageName)
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 50),
            imageView.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        let textStack = UIStackView()
        textStack.axis = .vertical
        textStack.spacing = 4
        
        let nameLabel = UILabel()
        nameLabel.text = name
        if #available(iOS 13.0, *) {
            nameLabel.font = .boldSystemFont(ofSize: 18)
        }
        nameLabel.numberOfLines = 1
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.8
        
        let roleLabel = UILabel()
        roleLabel.text = role
        roleLabel.font = .systemFont(ofSize: 14)
        if #available(iOS 13.0, *) {
            roleLabel.textColor = .secondaryLabel
        }
        roleLabel.numberOfLines = 1
        roleLabel.adjustsFontSizeToFitWidth = true
        roleLabel.minimumScaleFactor = 0.8
        
        textStack.addArrangedSubview(nameLabel)
        textStack.addArrangedSubview(roleLabel)
        
        horizontalStack.addArrangedSubview(imageView)
        horizontalStack.addArrangedSubview(textStack)
        
        card.addSubview(horizontalStack)
        NSLayoutConstraint.activate([
            horizontalStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 8),
            horizontalStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 0),
            horizontalStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: 0),
            horizontalStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -8)
        ])
        
        return card
    }
    
    private func addTapGesture(to view: UIView, with username: String) {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleCardTap(_:)))
        view.addGestureRecognizer(tapGesture)
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
    
    @objc private func openSourceCode() {
        UIApplication.shared.open(sourceCodeURL)
    }
    
    @objc private func colorSchemeSelected(_ sender: UIButton) {
        if let scheme = AppColorSchemeManager.ColorScheme.allCases.first(where: { $0.hashValue == sender.tag }) {
            selectedColorScheme = scheme
        }
    }
    
    #if DEBUG || TESTFLIGHT
    @objc private func resetOnboarding() {
        LaunchBoardingHelper.resetOnboarding()
        self.showAlert(title: trans("Onboarding Reset"), message: trans("Will show on next launch."))
    }
    #endif
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
}
