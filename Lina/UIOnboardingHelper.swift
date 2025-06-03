//
//  UIOnboardingHelper.swift
//  Lina
//
//  Created by Snoolie Keffaber on 2025/05/18.
//

import UIKit
import UIOnboarding

struct UIOnboardingHelper {
    static let shouldShowOnboardingKey = "hasCompletedOnboarding"
    
    // MARK: - Configuration
    static func configuration() -> UIOnboardingViewConfiguration {
        return .init(
            appIcon: setUpIcon(),
            firstTitleLine: setUpFirstTitleLine(),
            secondTitleLine: setUpSecondTitleLine(),
            features: setUpFeatures(),
            textViewConfiguration: setUpNotice(),
            buttonConfiguration: setUpButton()
        )
    }
    
    private static func setUpIcon() -> UIImage {
        return UIImage(named: "LinaIcon") ?? UIImage()
    }
    
    private static func setUpFirstTitleLine() -> NSMutableAttributedString {
        return NSMutableAttributedString(
            string: "Welcome to",
            attributes: [.foregroundColor: UIColor.label]
        )
    }
    
    private static func setUpSecondTitleLine() -> NSMutableAttributedString {
        let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? "Lina"
        return NSMutableAttributedString(
            string: appName,
            attributes: [.foregroundColor: UIColor.systemPurple]
        )
    }
    
    private static func setUpFeatures() -> [UIOnboardingFeature] {
        return [
            /*UIOnboardingFeature(
                icon: UIImage(systemName: "lock.circle.fill") ?? UIImage(),
                title: "Secure Archives",
                description: "Create encrypted Apple Archives with military-grade encryption."
            ),*/
            UIOnboardingFeature(
                icon: UIImage(systemName: "archivebox.fill") ?? UIImage(),
                title: "Compression Support",
                description: "Compress files using LZFSE or other methods for efficient storage and transfer."
            ),
            UIOnboardingFeature(
                icon: UIImage(systemName: "signature") ?? UIImage(),
                title: "Digital Signatures",
                description: "Sign archives with ECDSA-P256 for authenticity and integrity verification."
            ),
            UIOnboardingFeature(
                icon: UIImage(systemName: "person.circle.fill") ?? UIImage(),
                title: "Open Source",
                description: "Built on open standards and transparent cryptography."
            )
        ]
    }
    
    private static func setUpNotice() -> UIOnboardingTextViewConfiguration {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        
        return UIOnboardingTextViewConfiguration(
            icon: UIImage(systemName: "exclamationmark.triangle") ?? UIImage(),
            text: "Version \(version)\nLina is developed open-source under MIT.",
            linkTitle: "View Source Code",
            link: "https://github.com/0xilis/Lina",
            tint: UIColor.systemPurple
        )
    }
    
    private static func setUpButton() -> UIOnboardingButtonConfiguration {
        return UIOnboardingButtonConfiguration(
            title: "Get Started",
            titleColor: .white,
            backgroundColor: UIColor.systemPurple
        )
    }
    
    static func showOnboardingIfNeeded(in viewController: UIViewController) {
        guard !UserDefaults.standard.bool(forKey: shouldShowOnboardingKey) else { return }
        
        let onboardingController = UIOnboardingViewController(withConfiguration: configuration())
        onboardingController.delegate = viewController as? UIOnboardingViewControllerDelegate
        onboardingController.modalPresentationStyle = .fullScreen
        viewController.present(onboardingController, animated: false)
    }
    
    static func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: shouldShowOnboardingKey)
    }
    
    #if DEBUG || TESTFLIGHT
    static func resetOnboarding() {
        UserDefaults.standard.removeObject(forKey: shouldShowOnboardingKey)
    }
    #endif
}
