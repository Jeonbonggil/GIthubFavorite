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
                fetchFavoriteData()
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
            if items.isFavorite {
                userInfo?.items[index].isFavorite = items.isFavorite
                saveFavoriteData(at: index)
            } else {
                removeFavorite(at: index)
            }
        }
        if searchType.value == .local {
            removeFavorite(at: index)
        }
        tableReload.accept(())
    }
    /// 즐겨찾기 저장 in core data
    func saveFavoriteData(at index: Int) {
        guard let item = userInfo?.items[safe: index] else { return }
        let model = Favorites(
            username: item.username,
            avatarURL: item.avatarURL,
            htmlURL: item.htmlURL,
            isFavorite: item.isFavorite
        )
        persistenceManager.saveFavorite(favorite: model)
        fetchFavoriteData()
    }
    /// 즐겨찾기 삭제
    private func removeFavorite(at index: Int) {
        let fetchResult = persistenceManager.fetch(request: fetchRequest)
        if searchType.value == .api {
            userInfo?.items[index].isFavorite = false
            if let foundIndex = fetchResult.firstIndex(where: {
                $0.username == userInfo?.items[safe: index]?.username
            }) {
                persistenceManager.deleteFavorite(object: fetchResult[foundIndex])
            }
        }
        if searchType.value == .local {
            if let foundIndex = userInfo?.items.firstIndex(where: {
                $0.username == favoriteList[index].username
            }) {
                userInfo?.items[foundIndex].isFavorite = false
            }
            if let foundIndex = fetchResult.firstIndex(where: {
                $0.username == favoriteList[index].username
            }) {
                persistenceManager.deleteFavorite(object: fetchResult[foundIndex])
            }
        }
        fetchFavoriteData()
    }
    /// 즐겨찾기 조회 및 정렬 in core data
    func fetchFavoriteData() {
        let favorites = persistenceManager.fetch(request: fetchRequest)
        favoriteList = favorites.sorted {
            $0.username?.localizedCaseInsensitiveCompare($1.username ?? "") == .orderedAscending
        }
        if searchType.value == .api {
            userInfo?.items.enumerated().forEach { i, item in
                if let _ = favorites.firstIndex(where: { $0.username == item.username }) {
                    userInfo?.items[i].isFavorite = true
                }
            }
        }
    }
    /// 즐겨찾기 검색
    func searchFavoriteUsers(to username: String) -> Void {
        //TODO: - 즐겨찾기 검색 구현
        print("즐겨찾기 검색: \(username)")
    }
}
