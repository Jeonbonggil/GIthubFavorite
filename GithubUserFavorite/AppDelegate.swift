//
//  AppDelegate.swift
//  GithubUserFavorite
//
//  Created by ec-jbg on 2024/05/03.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        if #available(iOS 15.0, *) {
            UITableView.appearance().sectionHeaderTopPadding = 0.0
        }
//        window = UIWindow(frame: UIScreen.main.bounds)
//        window?.rootViewController = ViewController()
//        window?.makeKeyAndVisible()
        return true
    }
    /// webview 이동
    func gotoUrl(to url: String?, vc: UIViewController?) {
        guard let url = url?.trimmingCharacters(in: .whitespacesAndNewlines),
              !url.isEmpty, url.hasPrefix("http") else { return }
        let controller = UserURLWebViewController(url: url)
        vc?.present(controller, animated: true, completion: nil)
    }
}
