//
//  UIViewController.swift
//  GithubUserFavorite
//
//  Created by ec-jbg on 2024/05/03.
//

import UIKit

extension UIViewController {
    func screen() -> UIScreen? {
        guard let window = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return view.window?.windowScene?.screen
        }
        return window.screen
    }
}
