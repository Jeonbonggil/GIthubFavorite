//
//  AlertController.swift
//  Sample
//
//  Created by africa on 2020/08/07.
//  Copyright © 2020 africa. All rights reserved.
//

import UIKit

extension UIAlertController {
   static func showMessage(_ msg: String) {
        let alert = UIAlertController(title: "", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        UIApplication.keyWindow().rootViewController?.present(alert, animated: true, completion: nil)
    }
}
