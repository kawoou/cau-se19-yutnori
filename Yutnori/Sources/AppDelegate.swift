//
//  AppDelegate.swift
//  Yutnori
//
//  Created by Kawoou on 25/05/2019.
//  Copyright © 2019 kawoou. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    lazy var dependency = AppDependency()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = {
            let window = UIWindow(frame: UIScreen.main.bounds)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
            viewController.viewModel = MainViewModel(service: dependency.service)
            window.rootViewController = viewController
            window.makeKeyAndVisible()
            return window
        }()

        return true
    }
}

