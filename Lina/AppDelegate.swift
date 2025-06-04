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
        clearTemporaryDirectory()
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .portrait
    }
    
    func application(_ application: UIApplication, handlerFor intent: INIntent) -> Any? {
                
        switch intent {
            case is CreateAARIntent:
                return CreateArchiveShortcutsActionHandler()
            case is ExtractAARIntent:
                return ExtractAARShortcutsActionHandler()
            default:
                return nil
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if ["aar", "aea", "yaa", "shortcut"].contains(url.pathExtension.lowercased()) {
            guard let rootVC = window?.rootViewController as? MainTabBarController else { return false }
            
            rootVC.selectedIndex = 1
            
            if let navController = rootVC.viewControllers?[1] as? UINavigationController,
               let extractVC = navController.viewControllers.first as? ExtractArchiveViewController {
                
                extractVC.fileURLFromShare = url
                
                navController.popToRootViewController(animated: false)
            }
            
            return true
        }
        return false
    }
}

class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let scheme = AppColorSchemeManager.current
        tabBar.tintColor = scheme.color
        navigationController?.navigationBar.tintColor = scheme.color
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
        
        let verifyVC = VerifyAEAViewController()
        let verifyImage = UIImage(systemName: "checkmark.shield") ?? UIImage()
        verifyVC.tabBarItem = UITabBarItem(title: "Verify", image: verifyImage, tag: 3)
        
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
                           UINavigationController(rootViewController: verifyVC),
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

func clearTemporaryDirectory() {
    let tempDirectoryURL = FileManager.default.temporaryDirectory
    do {
        let tempDirectoryContents = try FileManager.default.contentsOfDirectory(at: tempDirectoryURL, includingPropertiesForKeys: nil, options: [])
        for fileURL in tempDirectoryContents {
            do {
                try FileManager.default.removeItem(at: fileURL)
            } catch {
                print("Failed to remove file at \(fileURL.path): \(error)")
            }
        }
    } catch {
        print("Failed to read contents of temporary directory: \(error)")
    }
}
