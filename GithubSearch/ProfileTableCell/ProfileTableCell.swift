//
//  ProfileTableCell.swift
//  GithubUserFavorite
//
//  Created by Bonggil Jeon on 5/4/24.
//

import UIKit
import Kingfisher
import RxSwift
import RxGesture

final class ProfileTableCell: UITableViewCell, NibLoadable, ReusableView {
    @IBOutlet weak var initialWord: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var favoriteImage: UIImageView! {
        didSet {
            favoriteImage.rx
                .tapGesture()
                .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
                .when(.recognized)
                .subscribe { [weak self] _ in
                    guard let self else { return }
                    if viewModel.getSearchFavoriteCount() > 0 {
                        viewModel.removeSearchFavorite(at: index)
                    } else {
                        viewModel.toggleFavorite(at: index)
                    }
                }
                .disposed(by: bag)
        }
    }
    @IBOutlet var initialWordToProfileConst: NSLayoutConstraint!
    private var index: Int = 0
    private let bag = DisposeBag()
    var viewModel: GithubSearchViewModel = GithubSearchViewModel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImage.layer.cornerRadius = profileImage.frame.width / 2
        profileImage.layer.masksToBounds = true
        profileImage.layer.borderWidth = 1
        profileImage.layer.borderColor = UIColor.black.cgColor
    }
    /// 검색 API Cell 설정
    func configureCellToSearchAPI(at index: Int) {
        self.index = index
        initialWord.text = ""
        initialWordToProfileConst.isActive = false
        profileImage.kf.setImage(with: URL(string: viewModel.getUserProfile(at: index)))
        userName.text = viewModel.getUserName(at: index)
        favoriteImage.image = viewModel.getUserFavorite(at: index) ?
        UIImage(systemName: "star.fill") :
        UIImage(systemName: "star")
    }
    /// 로컬 즐겨찾기 Cell 설정
    func configureCellToLocal(at index: Int) {
        initialWord.text = viewModel.makeInitialWord(at: index)
        initialWordToProfileConst.isActive = true
        self.index = index
        profileImage.kf.setImage(with: URL(string: viewModel.getFavoriteUserProfile(at: index)))
        userName.text = viewModel.getFavoriteUserName(at: index)
        favoriteImage.image = UIImage(systemName: "star.fill")
    }
    /// 로컬 즐겨찾기 검색 Cell 설정
    func configureCellToLocalSearch(at index: Int) {
        initialWord.text = viewModel.makeInitialWord(at: index)
        initialWordToProfileConst.isActive = true
        self.index = index
        profileImage.kf.setImage(with: URL(string: viewModel.getSearchFavoriteUserProfile(at: index)))
        userName.text = viewModel.getSearchFavoriteUserName(at: index)
        favoriteImage.image = UIImage(systemName: "star.fill")
    }
}
