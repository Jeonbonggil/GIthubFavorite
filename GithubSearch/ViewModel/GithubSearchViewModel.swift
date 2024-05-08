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

/// 검색 타입
enum SearchType: Int, Equatable {
    case api
    case local
}

final class GithubSearchViewModel {
    /// API Manager
    private let apiManager = GitHubAPIManager.shared
    /// Persistence Manager
    private let persistenceManager = PersistenceManager.shared
    private let fetchRequest: NSFetchRequest<UserFavorites> = UserFavorites.fetchRequest()
    /// Loading View 노출 처리
    private let _loading = BehaviorRelay<Bool>(value: false)
    var loading: Driver<Bool> {
        return _loading.asDriver()
    }
    /// API 검색 Parameter
    var userParams: UserParameters
    /// API 검색 리스트
    var userInfo: UserInfo?
    /// API 검색어
    var searchWordInAPI = ""
    /// Local 즐겨찾기 리스트
    private var favoriteList = [UserFavorites]()
    /// Local 즐겨찾기 검색 리스트
    private var searchFavoriteList = [UserFavorites]()
    /// Local 즐겨찾기 검색어
    var searchWordInLocal = ""
    /// 검색 Type
    var searchType = BehaviorRelay<SearchType>(value: .api)
    var noSearchResult = BehaviorRelay<String>(value: "")
    /// Table 전체 Relaod
    var tableReload = BehaviorRelay<Void>(value: ())
    /// API Data Load More
    var isLoadingData = false
    
    //MARK: - Initialize
    
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
        loadMore: Bool = false,
        completion: @escaping (UserInfo) -> Void
    ) {
        GitHubAPIManager.searchUsers(param: param) { [weak self] userInfo in
            guard let self else { return }
            if loadMore {
                self.userInfo?.items.append(contentsOf: userInfo.items)
            } else {
                self.userInfo = userInfo
            }
            fetchFavoriteData()
            _loading.accept(false)
            completion(userInfo)
        } onFailure: { [weak self] error in
            print(error.localizedDescription)
            self?._loading.accept(false)
        }
    }
    /// TableView 최하단 Scroll 시, 사용자 더 불러오기
    func loadMoreData() {
        guard userInfo?.items.count ?? 0 > 25 else { return }
        isLoadingData = true
        userParams.page += 1
        _loading.accept(true)
        searchUsers(param: userParams, loadMore: true) { [weak self] _ in
            self?.isLoadingData = false
            self?.tableReload.accept(())
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

//MARK: - Local 즐겨찾기 Data

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
    /// 즐겨찾기 사용자 URL
    func getFavoriteUserURL(at index: Int) -> String {
        return favoriteList[safe: index]?.htmlURL ?? ""
    }
    /// 즐겨찾기 여부
    func getUserFavorite(at index: Int) -> Bool {
        guard let items = userInfo?.items[safe: index] else { return false }
        return items.isFavorite
    }
    /// 즐겨찾기 초성 만들기
    func makeInitialWord(at index: Int) -> String {
        var searchList = favoriteList
        if getSearchFavoriteCount() > 0 {
            searchList = searchFavoriteList
        }
        if index == 0 {
            return searchList[safe: index]?.username?.first?.uppercased() ?? ""
        } else {
            let preIndex = index - 1
            let preWord = searchList[safe: preIndex]?.username?.first?.uppercased() ?? ""
            let currentWord = searchList[safe: index]?.username?.first?.uppercased() ?? ""
            if preWord == currentWord {
                return ""
            } else {
                return currentWord
            }
        }
    }
    /// 즐겨찾기 Toggle in API
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
    /// 즐겨찾기 저장 in Core Data
    func saveFavoriteData(at index: Int) {
        guard let item = userInfo?.items[safe: index] else { return }
        let model = Favorites(
            initial: item.initial,
            username: item.username,
            avatarURL: item.avatarURL,
            htmlURL: item.htmlURL,
            isFavorite: item.isFavorite
        )
        persistenceManager.saveFavorite(favorite: model)
        fetchFavoriteData()
    }
    /// 즐겨찾기 삭제 in Core Data
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
    /// 즐겨찾기 리스트 갱신 및 정렬
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
            searchFavoriteUsers(to: searchWordInLocal)
        }
        if searchType.value == .local, getSearchFavoriteCount() > 0 {
            searchFavoriteUsers(to: searchWordInLocal)
        }
    }
}

//MARK: - 즐겨찾기 검색 Data

extension GithubSearchViewModel {
    /// 즐겨찾기 검색
    func searchFavoriteUsers(to username: String) {
        searchFavoriteList = favoriteList.filter {
            $0.username?.lowercased().contains(username) == true
        }
    }
    /// 즐겨찾기 검색 리스트 Count
    func getSearchFavoriteCount() -> Int {
        return searchFavoriteList.count
    }
    /// 즐겨찾기 검색 사용자 이름
    func getSearchFavoriteUserName(at index: Int) -> String {
        return searchFavoriteList[safe: index]?.username ?? ""
    }
    /// 즐겨찾기 검색 사용자 Profile Image URL
    func getSearchFavoriteUserProfile(at index: Int) -> String {
        return searchFavoriteList[safe: index]?.avatarURL ?? ""
    }
    /// 즐겨찾기 검색 사용자 URL
    func getSearchFavoriteUserURL(at index: Int) -> String {
        return searchFavoriteList[safe: index]?.htmlURL ?? ""
    }
    /// 즐겨찾기 검색 후 즐겨찾기 삭제
    func removeSearchFavorite(at index: Int) {
        guard let item = searchFavoriteList[safe: index] else { return }
        if let foundIndex = favoriteList.firstIndex(where: { $0.username == item.username }) {
            removeFavorite(at: foundIndex)
            tableReload.accept(())
        }
    }
}
