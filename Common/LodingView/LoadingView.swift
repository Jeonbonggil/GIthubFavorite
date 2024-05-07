//
//  LoadingView.swift
//  GithubUserFavorite
//
//  Created by ec-jbg on 2024/05/07.
//

import UIKit
import SnapKit

final class LoadingView: UIView {
    private let indicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        indicator.style = .large
        indicator.color = .gray
//        indicator.startAnimating()
        return indicator
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        appDelegate.window?.bringSubviewToFront(self)
        appDelegate.window?.rootViewController?.view.addSubview(self)
        addSubview(indicator)
        indicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show() {
        indicator.startAnimating()
        isHidden = false
    }
    
    func hide() {
        indicator.stopAnimating()
        isHidden = true
    }
}
