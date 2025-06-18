//
//  AppDelegate.swift
//  Lina
//
//  Created by Snoolie Keffaber on 2025/05/17.
//

import UIKit
import Intents

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let rootVC = MainTabBarController()
        window?.rootViewController = rootVC
        window?.makeKeyAndVisible()
        //LaunchBoardingHelper.showOnboardingIfNeeded(in: rootVC)
        clearTemporaryDirectory()
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .portrait
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
            createVC.tabBarItem = UITabBarItem(title: trans("Create"), image: createVCImage, tag: 0)
        } else {
            createVCImage = UIImage(named: "folder")?.tabBarIcon() ?? UIImage()
            createVC.tabBarItem = UITabBarItem(title: trans("Create"), image: createVCImage, tag: 0)
            //createVC.tabBarItem.imageInsets = UIEdgeInsets(top: 85, left: 85, bottom: 85, right: 85)
        }
        
        let extractVC = ExtractArchiveViewController()
        var extractVCImage = UIImage()
        if #available(iOS 13, *) {
            extractVCImage = UIImage(systemName: "archivebox") ?? UIImage()
            extractVC.tabBarItem = UITabBarItem(title: trans("Extract"), image: extractVCImage, tag: 1)
        } else {
            extractVCImage = UIImage(named: "archivebox")?.tabBarIcon() ?? UIImage()
            extractVC.tabBarItem = UITabBarItem(title: trans("Extract"), image: extractVCImage, tag: 1)
            //extractVC.tabBarItem.imageInsets = UIEdgeInsets(top: 85, left: 85, bottom: 85, right: 85)
        }
        
        let verifyVC = VerifyAEAViewController()
        if #available(iOS 13, *) {
            let verifyImage = UIImage(systemName: "checkmark.shield") ?? UIImage()
            verifyVC.tabBarItem = UITabBarItem(title: trans("Verify"), image: verifyImage, tag: 3)
        } else {
            let verifyImage = UIImage(named: "checkmark.shield")?.tabBarIcon() ?? UIImage()
            verifyVC.tabBarItem = UITabBarItem(title: trans("Verify"), image: verifyImage, tag: 3)
            //verifyVC.tabBarItem.imageInsets = UIEdgeInsets(top: 85, left: 85, bottom: 85, right: 85)
        }
        
        let creditsVC = CreditsViewController()
        var creditsVCImage = UIImage()
        if #available(iOS 13, *) {
            creditsVCImage = UIImage(systemName: "heart") ?? UIImage()
            creditsVC.tabBarItem = UITabBarItem(title: trans("Credits"), image: creditsVCImage, tag: 2)
        } else {
            creditsVCImage = UIImage(named: "heart")?.tabBarIcon() ?? UIImage()
            creditsVC.tabBarItem = UITabBarItem(title: trans("Credits"), image: creditsVCImage, tag: 2)
            //creditsVC.tabBarItem.imageInsets = UIEdgeInsets(top: 85, left: 85, bottom: 85, right: 85)
        }
        
        viewControllers = [UINavigationController(rootViewController: createVC),
                           UINavigationController(rootViewController: extractVC),
                           UINavigationController(rootViewController: verifyVC),
                           UINavigationController(rootViewController: creditsVC)]
    }
}

/*
 
 TODO: In the future move LaunchBoardingDelagate to MainTabBarController instead of the CreateArchiveViewController
 
}*/

extension UIImage {
    func aspectFitted(to size: CGSize) -> UIImage {
        let aspectRatio = self.size.width / self.size.height
        var targetSize = size
        
        if size.width / aspectRatio > size.height {
            targetSize.width = size.height * aspectRatio
        } else {
            targetSize.height = size.width / aspectRatio
        }
        
        return self.resized(to: targetSize)
    }
    
    func resized(to size: CGSize) -> UIImage {
        if #available(iOS 10.0, *) {
            return UIGraphicsImageRenderer(size: size).image { _ in
                self.draw(in: CGRect(origin: .zero, size: size))
            }
        } else {
            UIGraphicsBeginImageContextWithOptions(size, false, self.scale)
            self.draw(in: CGRect(origin: .zero, size: size))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return resizedImage ?? self
        }
    }
    
    func tabBarIcon() -> UIImage {
        let maxSize = CGSize(width: 25, height: 25)
        return self.aspectFitted(to: maxSize).withRenderingMode(.alwaysTemplate)
    }
}

func clearTemporaryDirectory() {
    var tempDirectoryURL: URL
    if #available(iOS 10.0, *) {
        tempDirectoryURL = FileManager.default.temporaryDirectory
    } else {
        let tempDirPath = NSTemporaryDirectory()
        tempDirectoryURL = URL(fileURLWithPath: tempDirPath)
    }
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

func trans(_ text: String) -> String {
    return NSLocalizedString(text, comment: "")
}
