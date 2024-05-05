//
//  GithubSearchViewModel.swift
//  GithubUserFavorite
//
//  Created by Bonggil Jeon on 5/4/24.
//

import Foundation
import RxCocoa
import RxSwift

enum SearchError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
    case decodeError
}

enum SearchType: Int, Equatable {
    case api
    case local
}

class GithubSearchViewModel {
    private let apiManager = GitHubAPIManager.shared
    var userParams: UserParameters
    /// API 검색 리스트
    var userInfo: UserInfo? = nil
    /// 로컬 즐겨찾기 리스트
    var favoriteList: [Item] = []
    var searchType = BehaviorRelay<SearchType>(value: .api)
    var tableReload = BehaviorRelay<Void>(value: ())
    var tableReloadRows = BehaviorRelay<Int>(value: 0)
    
    init() {
        userParams = UserParameters(name: "", page: 1, perPage: 30)
    }
}

//MARK: - API Data

extension GithubSearchViewModel {
    /// User 검색 API
    func searchUsers(
        param: UserParameters,
        completion: @escaping (Result<UserInfo, Error>) -> Void
    ) {
        GitHubAPIManager.searchUsers(param: param) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(response):
                userInfo = response
                completion(.success(response))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    /// API 검색 리스트 갯수
    func getUserCount() -> Int {
        return userInfo?.items.count ?? 0
    }
    /// 사용자 이름
    func getUserName(at index: Int) -> String {
        return userInfo?.items[safe: index]?.login ?? ""
    }
    /// 사용자 Profile Image URL
    func getUserProfile(at index: Int) -> String {
        return userInfo?.items[safe: index]?.avatarURL ?? ""
    }
    /// 사용자 URL
    func getUserURL(at index: Int) -> String {
        return userInfo?.items[safe: index]?.url ?? ""
    }
}

//MARK: - Local Data

extension GithubSearchViewModel {
    /// 로컬 즐겨찾기 리스트 갯수
    func getLocalUserCount() -> Int {
        return favoriteList.count
    }
    /// 즐겨찾기 여부
    func getUserFavorite(at index: Int) -> Bool {
        guard let items = userInfo?.items[safe: index] else { return false }
        return items.isFavorite
    }
    /// 즐겨찾기 토글
    func toggleFavorite(at index: Int) {
        guard var items = userInfo?.items[safe: index] else { return }
        items.isFavorite.toggle()
        userInfo?.items[index].isFavorite = items.isFavorite
        if items.isFavorite {
            addFavorite(at: index)
        } else {
            removeFavorite(at: index)
        }
        tableReloadRows.accept(index)
    }
    /// 즐겨찾기 추가
    private func addFavorite(at index: Int) {
        guard let item = userInfo?.items[safe: index] else { return }
        favoriteList.append(item)
    }
    /// 즐겨찾기 삭제
    private func removeFavorite(at index: Int) {
        guard let item = userInfo?.items[safe: index] else { return }
        favoriteList.removeAll { $0.isFavorite == false }
    }
    /// 즐겨찾기 리스트
    func getFavoriteList() -> UserInfo {
        var items: [Item] = []
        favoriteList.forEach { item in
            if let item = userInfo?.items.first(where: { $0.isFavorite }) {
                items.append(item)
            }
        }
        return UserInfo(incomplete_results: false, items: items, total_count: items.count)
    }
    /// 즐겨찾기 조회
    func searchFavoriteUsers() {
        userInfo = getFavoriteList()
    }
}
