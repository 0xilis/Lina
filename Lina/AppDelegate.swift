//
//  AppDelegate.swift
//  Lina
//
//  Created by Snoolie Keffaber on 2025/05/17.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = MainTabBarController()
        window?.makeKeyAndVisible()
        return true
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
}
