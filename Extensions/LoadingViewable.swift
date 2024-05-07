//
//  LoadingViewable.swift
//  MVVMRx
//
//  Created by Mohammad Zakizadeh on 7/26/18.
//  Copyright © 2018 Storm. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

protocol LoadingViewable {
    func startAnimating()
    func stopAnimating()
}

extension UIView: LoadingViewable {
    // MARK: - LoadingViewable
}

extension LoadingViewable where Self: UIView {
    func startAnimating() {
        let loadingView = LoadingView(
            frame: CGRect(x: 0, y: 0, width: Screen.width, height: Screen.height)
        )
        loadingView.show()
    }
    
    func stopAnimating() {
        let loadingView = LoadingView(
            frame: CGRect(x: 0, y: 0, width: Screen.width, height: Screen.height)
        )
        loadingView.hide()
    }
}

extension Reactive where Base: UIView {
    /// Bindable sink for `startAnimating()`, `stopAnimating()` methods.
    public var isAnimating: Binder<Bool> {
        return Binder(self.base, binding: { (view, loading) in
            if loading {
                view.startAnimating()
            } else {
                view.stopAnimating()
            }
        })
    }
}
