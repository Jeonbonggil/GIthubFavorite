//
//  AlertController.swift
//  GithubUserFavorite
//
//  Created by Bonggil Jeon on 5/4/24.
//

import UIKit

extension UIAlertController {
   static func showMessage(_ msg: String) {
        let alert = UIAlertController(title: "", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        UIApplication.keyWindow().rootViewController?.present(alert, animated: true, completion: nil)
    }
}
