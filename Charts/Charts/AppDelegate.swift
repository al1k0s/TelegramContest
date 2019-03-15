//
//  AppDelegate.swift
//  Charts
//
//  Created by Oleksii Andriushchenko on 3/10/19.
//  Copyright © 2019 Алексей Андрющенко. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    let window = UIWindow()
    self.window = window

    let navController = UINavigationController()
    window.rootViewController = navController
    window.makeKeyAndVisible()

    let presenter = Presenter()
    let viewController = ViewController(presenter: presenter)
    presenter.viewController = viewController

    navController.setViewControllers([viewController], animated: false)
    return true
  }
}

