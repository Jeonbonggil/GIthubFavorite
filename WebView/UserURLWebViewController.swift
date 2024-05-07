//
//  UserURLWebViewController.swift
//  GithubUserFavorite
//
//  Created by ec-jbg on 2024/05/07.
//

import UIKit
import WebKit
import SnapKit

class UserURLWebViewController: UIViewController, WKNavigationDelegate, UIScrollViewDelegate, WKUIDelegate {
    var url: String?
    private var webView = WKWebView()
    
    init(url: String) {
        super.init(nibName: nil, bundle: nil)
        self.url = url
        let configuration = WKWebViewConfiguration()
        webView.navigationDelegate = self
        webView.scrollView.delegate = self
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView = WKWebView(
            frame: CGRect(x: 0, y: 0, width: Screen.width, height: Screen.height),
            configuration: configuration
        )
        view.addSubview(webView)
        webView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        webView.load(URLRequest(url: URL(string: url)!))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
