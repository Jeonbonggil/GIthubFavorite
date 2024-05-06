//
//  GitHubSearchVC.swift
//  GithubUserFavorite
//
//  Created by ec-jbg on 2024/05/03.
//

import UIKit
import RxSwift
import RxGesture
import SnapKit

final class GitHubSearchVC: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var APIButtonView: UIView! {
        didSet {
            APIButtonView.rx
                .tapGesture()
                .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
                .when(.recognized)
                .subscribe { [weak self] _ in
                    guard let self else { return }
                    moveLineViewLeading.constant = 0
                    UIView.animate(
                        withDuration: 0.2,
                        delay: 0,
                        options: .curveEaseInOut
                    ) { [weak self] in
                        self?.view.layoutIfNeeded()
                    } completion: { [weak self] _ in
                        self?.viewModel.searchType.accept(.api)
                    }
                }
                .disposed(by: bag)
        }
    }
    @IBOutlet weak var LocalButtonView: UIView! {
        didSet {
            LocalButtonView.rx
                .tapGesture() 
                .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
                .when(.recognized)
                .subscribe { [weak self] _ in
                    guard let self else { return }
                    moveLineViewLeading.constant = Screen.width / 2
                    UIView.animate(
                        withDuration: 0.2,
                        delay: 0,
                        options: .curveEaseInOut
                    ) { [weak self] in
                        self?.view.layoutIfNeeded()
                    } completion: { [weak self] _ in
                        self?.textField.text = ""
                        self?.viewModel.searchType.accept(.local)
                    }
                }
                .disposed(by: bag)
        }
    }
    @IBOutlet weak var moveLineViewLeading: NSLayoutConstraint!
    @IBOutlet weak var textField: UITextField! {
        didSet {
            textField.delegate = self
        }
    }
    @IBOutlet weak var profileTableView: UITableView! {
        didSet {
            profileTableView.delegate = self
            profileTableView.dataSource = self
            profileTableView.register(ProfileTableCell.self)
        }
    }
    private lazy var noSearchResultView = {
        let view = UIView()
        view.backgroundColor = .white
        let label = UILabel()
        label.text = "검색 결과가 없습니다."
        label.font = .systemFont(ofSize: 20)
        label.textColor = .black
        label.textAlignment = .center
        view.addSubview(label)
        label.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        view.isHidden = true
        return view
    }()
    private let bag = DisposeBag()
    private var viewModel = GithubSearchViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindRx()
        view.addSubview(noSearchResultView)
        noSearchResultView.snp.makeConstraints {
            $0.edges.equalTo(profileTableView)
        }
    }
    
    private func bindRx() {
        view.rx
            .tapGesture()
            .when(.recognized)
            .subscribe { [weak self] _ in
                self?.textField.resignFirstResponder()
            }
            .disposed(by: bag)
        
        viewModel
            .tableReload
            .skip(1)
            .asDriver(onErrorJustReturn: ())
            .drive { [weak self] _ in
                DispatchQueue.main.async {
                    self?.profileTableView.reloadData()
                }
            }
            .disposed(by: bag)
        
        viewModel
            .searchType
            .skip(1)
            .asDriver(onErrorJustReturn: .api)
            .drive { [weak self] searchType in
                self?.viewModel.tableReload.accept(())
            }
            .disposed(by: bag)
        
        textField.rx
            .controlEvent(.editingDidEndOnExit)
            .subscribe { [weak self] _ in
                guard let self, let text = textField.text else { return }
                if text.isEmpty {
                    UIAlertController.showMessage("검색어를 입력해주세요.")
                    return
                }
                viewModel.userParams = UserParameters(name: text, page: 1, perPage: 30)
                guard case .api = viewModel.searchType.value else { return }
                viewModel.searchUsers(param: viewModel.userParams) { [weak self] _ in
                    guard let self else { return }
                    viewModel.tableReload.accept(())
                    if !text.isEmpty, viewModel.getUserCount() == 0 {
                        noSearchResultView.isHidden = false
                    } else {
                        noSearchResultView.isHidden = true
                    }
                }
                textField.resignFirstResponder()
            }
            .disposed(by: bag)
        
        textField.rx
            .controlEvent(.editingChanged)
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .subscribe { [weak self] _ in
                guard let self, let text = textField.text,
                      case .local = viewModel.searchType.value else { return }
                viewModel.searchFavoriteUsers(to: text)
                viewModel.tableReload.accept(())
                if !text.isEmpty, viewModel.getSearchFavoriteCount() == 0 {
                    noSearchResultView.isHidden = false
                } else {
                    noSearchResultView.isHidden = true
                }
            }
            .disposed(by: bag)
    }
}

//MARK: - UITableViewDataSource, UITableViewDelegate

extension GitHubSearchVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch viewModel.searchType.value {
        case .api:
            return viewModel.getUserCount()
        case .local:
            if viewModel.getSearchFavoriteCount() > 0 {
                return viewModel.getSearchFavoriteCount()
            }
            return viewModel.getLocalUserCount()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as ProfileTableCell
        cell.viewModel = viewModel
        switch viewModel.searchType.value {
        case .api:
            cell.configureCellToSearchAPI(at: indexPath.row)
        case .local:
            if viewModel.getSearchFavoriteCount() > 0 {
                cell.configureCellToLocalSearch(at: indexPath.row)
            } else {
                cell.configureCellToLocal(at: indexPath.row)
            }
        }
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("didSelectRowAt: \(indexPath.row)")
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        textField.resignFirstResponder()
    }
}
