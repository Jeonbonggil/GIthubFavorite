//
//  Application.swift
//  GithubUserSearch
//
//  Created by Bonggil Jeon on 5/4/24.
//

import UIKit

extension UIApplication {
    static func keyWindow() -> UIWindow {
        var keyWindow: UIWindow? = nil
        if #available(iOS 13.0, *) {
            keyWindow = UIApplication.shared.connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .map { $0 as? UIWindowScene }
                .compactMap { $0 }
                .first?.windows
                .filter { $0.isKeyWindow }
                .first
        } else {
            keyWindow = UIApplication.shared.keyWindow
        }
        return keyWindow ?? UIWindow()
    }
}
