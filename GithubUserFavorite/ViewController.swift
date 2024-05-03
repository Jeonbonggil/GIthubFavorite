//
//  ViewController.swift
//  GithubUserFavorite
//
//  Created by ec-jbg on 2024/05/03.
//

import UIKit
import RxSwift
import rxgesture

class ViewController: UIViewController {
    @IBOutlet weak var APIButtonView: UIView! {
        didSet {
            APIButtonView.rx

                
        }
    }
    @IBOutlet weak var LocalButtonView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}
