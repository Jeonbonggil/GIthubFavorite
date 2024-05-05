//
//  CommonFunc.swift
//  GithubUserFavorite
//
//  Created by Bonggil Jeon on 5/3/24.
//

import UIKit
import CoreData

struct Application {
    static var keyWindow: UIWindow {
        return UIApplication.shared.windows.first { $0.isKeyWindow } ?? UIWindow()
    }
}

struct Screen {
    static var width: CGFloat {
        return UIScreen.main.bounds.size.width
    }
    static var height: CGFloat {
        return UIScreen.main.bounds.size.height
    }
    static var statusBarHeight: CGFloat {
        return Application.keyWindow.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
    }
}

let appDelegate = UIApplication.shared.delegate as! AppDelegate
