//
//  GitHubAPI.swift
//  GithubUserFavorite
//
//  Created by Bonggil Jeon on 5/3/24.
//

import Foundation
import Moya

// MARK: - Provider support
public struct UserParameters {
    var name: String
    var page: Int
    var perPage: Int
}

public enum GitHubAPI {
    case searchUsers(UserParameters)
}

extension GitHubAPI: TargetType {
    public var baseURL: URL {
        return URL(string: "https://api.github.com")!
    }
    public var path: String {
        switch self {
        case .searchUsers:
            return "search/users"
        }
    }
    public var method: Moya.Method {
        switch self {
        case .searchUsers:
            return .get
        }
    }
    public var task: Task {
        switch self {
        case .searchUsers(let param):
            return .requestParameters(
                parameters: [
                    "q": param.name,
                    "order": "asc",
                    "page": param.page,
                    "per_page": param.perPage
                ],
                encoding: URLEncoding.default
            )
        }
    }
    public var validationType: ValidationType {
        switch self {
        case .searchUsers:
            return .successCodes
        }
    }
    public var headers: [String: String]? {
        let headers = [
            "Accept": "application/vnd.github+json",
            "X-GitHub-Api-Version": "2022-11-28"
        ]
        return headers
    }
    public var sampleData: Data {
        switch self {
        case .searchUsers(let name):
            return "{\"login\": \"\(name)\", \"id\": 100}".data(using: .utf8)!
        }
    }
}

public func url(_ route: TargetType) -> String {
    route.baseURL.appendingPathComponent(route.path).absoluteString
}
