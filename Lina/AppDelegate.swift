//
//  AppDelegate.swift
//  Lina
//
//  Created by Snoolie Keffaber on 2025/05/17.
//

import UIKit
import UIOnboarding
import Intents

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let rootVC = MainTabBarController()
        window?.rootViewController = rootVC
        window?.makeKeyAndVisible()
        UIOnboardingHelper.showOnboardingIfNeeded(in: rootVC)
        AppIntent.allowSiri()
        AppIntent.archive()
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .portrait
    }
    
    func application(_ application: UIApplication, handlerFor intent: INIntent) -> Any? {
                
        switch intent {
            // If the intent being responded to is GetPeople, call the GetPeople intent handler
            case is CreateAppleArchiveIntent:
                return CreateArchiveShortcutsActionHandler()
            default:
                return nil
        }
    }
}

class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let createVC = CreateArchiveViewController()
        var createVCImage = UIImage()
        if #available(iOS 13, *) {
            createVCImage = UIImage(systemName: "folder") ?? UIImage()
        } else {
            createVCImage = UIImage() // TODO: Placeholder until I do something else
        }
        createVC.tabBarItem = UITabBarItem(title: "Create", image: createVCImage, tag: 0)
        
        let extractVC = ExtractArchiveViewController()
        var extractVCImage = UIImage()
        if #available(iOS 13, *) {
            extractVCImage = UIImage(systemName: "archivebox") ?? UIImage()
        } else {
            extractVCImage = UIImage() // TODO: Placeholder until I do something else
        }
        extractVC.tabBarItem = UITabBarItem(title: "Extract", image: extractVCImage, tag: 1)
        
        let creditsVC = CreditsViewController()
        var creditsVCImage = UIImage()
        if #available(iOS 13, *) {
            creditsVCImage = UIImage(systemName: "heart") ?? UIImage()
        } else {
            creditsVCImage = UIImage() // TODO: Placeholder until I do something else
        }
        creditsVC.tabBarItem = UITabBarItem(title: "Credits", image: creditsVCImage, tag: 2)
        
        viewControllers = [UINavigationController(rootViewController: createVC),
                           UINavigationController(rootViewController: extractVC),
                           UINavigationController(rootViewController: creditsVC)]
    }
    
    func didTapButton(_ onboardingViewController: UIOnboardingViewController) {
        onboardingViewController.dismiss(animated: true) {
            UIOnboardingHelper.completeOnboarding()
        }
    }
        
    func didTapLink(_ onboardingViewController: UIOnboardingViewController, url: URL) {
        UIApplication.shared.open(url)
    }
}

extension MainTabBarController: UIOnboardingViewControllerDelegate {
    func didFinishOnboarding(onboardingViewController: UIOnboardingViewController) {
        onboardingViewController.dismiss(animated: true) {
            UIOnboardingHelper.completeOnboarding()
        }
    }
    
    func didTapLink(onboardingViewController: UIOnboardingViewController, url: URL) {
        UIApplication.shared.open(url)
    }
}
