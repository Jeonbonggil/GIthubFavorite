//
//  GithubSearchViewModel.swift
//  GithubUserFavorite
//
//  Created by Bonggil Jeon on 5/4/24.
//

import Foundation
import RxCocoa
import RxSwift
import CoreData

enum SearchError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
    case decodeError
}

/// 검색 타입
enum SearchType: Int, Equatable {
    case api
    case local
}

class GithubSearchViewModel {
    /// API Manager
    private let apiManager = GitHubAPIManager.shared
    /// Persistence Manager
    private let persistenceManager = PersistenceManager.shared
    private let fetchRequest: NSFetchRequest<UserFavorites> = UserFavorites.fetchRequest()
    var userParams: UserParameters
    /// API 검색 리스트
    var userInfo: UserInfo?
    /// 로컬 즐겨찾기 리스트
    var favoriteList = [UserFavorites]()
    /// 검색 Type
    var searchType = BehaviorRelay<SearchType>(value: .api)
    /// Table 전체 Relaod
    var tableReload = BehaviorRelay<Void>(value: ())
    /// Table 특정 Row Relaod
    var tableReloadRows = BehaviorRelay<Int>(value: 0)
    
    init() {
        userParams = UserParameters(name: "", page: 1, perPage: 30)
        userInfo = nil
        fetchFavoriteData()
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
            guard let self else { return }
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
        return userInfo?.items[safe: index]?.username ?? ""
    }
    /// 사용자 Profile Image URL
    func getUserProfile(at index: Int) -> String {
        return userInfo?.items[safe: index]?.avatarURL ?? ""
    }
    /// 사용자 URL
    func getUserURL(at index: Int) -> String {
        return userInfo?.items[safe: index]?.htmlURL ?? ""
    }
}

//MARK: - Local Data

extension GithubSearchViewModel {
    /// 즐겨찾기 List Count
    func getLocalUserCount() -> Int {
        return persistenceManager.count(request: fetchRequest) ?? 0
    }
    /// 즐겨찾기 사용자 이름
    func getFavoriteUserName(at index: Int) -> String {
        return favoriteList[safe: index]?.username ?? ""
    }
    /// 즐겨찾기 사용자 Profile Image URL
    func getFavoriteUserProfile(at index: Int) -> String {
        return favoriteList[safe: index]?.avatarURL ?? ""
    }
    /// 즐겨찾기 여부
    func getUserFavorite(at index: Int) -> Bool {
        guard let items = userInfo?.items[safe: index] else { return false }
        return items.isFavorite
    }
    /// 즐겨찾기 Toggle
    func toggleFavorite(at index: Int) {
        if searchType.value == .api {
            guard var items = userInfo?.items[safe: index] else { return }
            items.isFavorite.toggle()
            userInfo?.items[index].isFavorite = items.isFavorite
            if items.isFavorite {
                addFavorite(at: index)
            } else {
                removeFavorite()
            }
            tableReloadRows.accept(index)
        }
        if searchType.value == .local {
            removeFavorite(at: index)
            tableReload.accept(())
        }
    }
    /// 즐겨찾기 추가
    private func addFavorite(at index: Int) {
        saveFavoriteData(at: index)
    }
    /// 즐겨찾기 삭제
    private func removeFavorite(at index: Int = 0) {
        if searchType.value == .api {
            favoriteList.removeAll { $0.favorite }
        }
        if searchType.value == .local {
            let fetchResult = persistenceManager.fetch(request: fetchRequest)
            if let foundIndex = fetchResult.firstIndex(where: {
                $0.username == favoriteList[index].username
            }) {
                userInfo?.items[foundIndex].isFavorite = false
                persistenceManager.deleteFavorite(object: fetchResult[foundIndex])
            }
        }
    }
    /// 즐겨찾기 검색
    func searchFavoriteUsers(to username: String) -> Void {
        //TODO: - 즐겨찾기 검색 구현
//        userInfo = getFavoriteList(userID)
    }
    /// 즐겨찾기 저장 in core data
    func saveFavoriteData(at index: Int = 0) {
        guard let item = userInfo?.items[safe: index] else { return }
        let model = Favorites(
            username: item.username,
            avatarURL: item.avatarURL,
            htmlURL: item.htmlURL,
            isFavorite: item.isFavorite
        )
        persistenceManager.saveFavorite(favorite: model)
        print("즐겨찾기 저장 in core data")
    }
    /// 즐겨찾기 조회 in core data
    func fetchFavoriteData() {
        let favorites = persistenceManager.fetch(request: fetchRequest)
        favoriteList = favorites
    }
}
