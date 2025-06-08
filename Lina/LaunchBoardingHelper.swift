//
//  UIOnboardingHelper.swift
//  Lina
//
//  Created by Snoolie Keffaber on 2025/05/18.
//

import UIKit

struct LaunchBoardingHelper {
    static let shouldShowOnboardingKey = "hasCompletedOnboarding"
    
    static func showOnboardingIfNeeded(in viewController: CreateArchiveViewController) {
        #if !DEBUG
        guard !UserDefaults.standard.bool(forKey: shouldShowOnboardingKey) else { return }
        #endif
        
        /* LaunchBoarding, not included currently due to being very unfinished... */
        let page1icon = UIImage(named: "archiveboxfill") ?? UIImage()
        let page1 = LaunchBoardingPage.init(icon: page1icon.withRenderingMode(.alwaysTemplate), title: "Compression Support", descriptionText: "Compress files using LZFSE or other methods for efficient storage and transfer.", showButton: false)
        let page2icon = UIImage(named: "signature") ?? UIImage()
        let page2 = LaunchBoardingPage.init(icon: page2icon.withRenderingMode(.alwaysTemplate), title: "Digital Signatures", descriptionText: "Sign archives with ECDSA-P256 for authenticity and integrity verification.", showButton: false)
        var page3icon: UIImage
        if #available(iOS 13, *) {
            page3icon = UIImage(systemName: "person.circle.fill") ?? UIImage()
        } else {
            // TODO: .withRenderingMode(.alwaysTemplate) on this will fill in the person, so it will just be a circle
            page3icon = UIImage(named: "person.circle.fill") ?? UIImage()
        }
        let page3 = LaunchBoardingPage.init(icon: page3icon, title: "Open Source", descriptionText: "Built on open standards and transparent cryptography.", showButton: false)
        let config = LaunchBoardingConfiguration.init(pages: [page1, page2, page3])
        config.tintColor = AppColorSchemeManager.current.color
        config.buttonColor = AppColorSchemeManager.current.color
        config.shouldShowSkipButton = false
        config.showWelcomePage = true
        config.autoAdvanceWelcomePage = true
        
        let onboarding = LaunchBoardingController.init(configuration: config)
        onboarding.onboardingDelegate = viewController
        onboarding.modalPresentationStyle = .fullScreen
        viewController.onboardingController = onboarding
        
        viewController.present(onboarding, animated: false)
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
