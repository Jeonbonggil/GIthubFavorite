//
//  UIViewController.swift
//  GithubUserFavorite
//
//  Created by Bonggil Jeon on 5/4/24.
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
