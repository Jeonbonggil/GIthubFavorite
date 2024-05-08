//
//  LoadingView.swift
//  GithubUserFavorite
//
//  Created by ec-jbg on 2024/05/07.
//

import UIKit
import SnapKit

final class LoadingView: UIView {
    static let shared = LoadingView()
    private let bgView: UIView = {
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: Screen.width, height: Screen.height)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        return view
    }()
    private let indicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        indicator.style = .large
        indicator.color = .white
        return indicator
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = CGRect(x: 0, y: 0, width: Screen.width, height: Screen.height)
        backgroundColor = .clear
        appDelegate.window?.rootViewController?.view.addSubview(self)
        appDelegate.window?.bringSubviewToFront(self)
        addSubview(bgView)
        addSubview(indicator)
        bgView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
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
