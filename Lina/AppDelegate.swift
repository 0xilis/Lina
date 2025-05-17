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
        createVC.tabBarItem = UITabBarItem(title: "Create", image: UIImage(systemName: "folder"), tag: 0)
        
        let extractVC = ExtractArchiveViewController()
        extractVC.tabBarItem = UITabBarItem(title: "Extract", image: UIImage(systemName: "archivebox"), tag: 1)
        
        viewControllers = [UINavigationController(rootViewController: createVC),
                           UINavigationController(rootViewController: extractVC)]
    }
}
