//
//  AppDelegate.swift
//  DoggyApp
//
//  Created by Flaviu Adrian Suciu on 30.10.2022.
//

import UIKit

extension UIApplication {
        class func isFirstLaunch() -> Bool {
            if !UserDefaults.standard.bool(forKey: "hasBeenLaunchedBeforeFlag") {
                UserDefaults.standard.set(true, forKey: "hasBeenLaunchedBeforeFlag")
                UserDefaults.standard.synchronize()
                return true
            }
            return false
        }
    }

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    if UIApplication.isFirstLaunch() {
            PersistanceManager.shared.fetchTokenFromWebServiceAndSave() //fetch token
    } else {
            PersistanceManager.shared.checkTokenValidityAndRefetchIfNeeded() //check if current token expired and if so, refetch
    }
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

