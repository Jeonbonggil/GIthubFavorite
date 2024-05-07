//
//  GitHubAPIManager.swift
//  GithubUserFavorite
//
//  Created by Bonggil Jeon on 5/4/24.
//

import Foundation
import Moya

public enum APIError: Error {
    case invalidURL
    case invalidResponse
    case invalidData(message: String? = nil)
    case decodeError
    
    var localizedDescription: String {
        return message()
    }
    
    func message() -> String {
        switch self {
        case .invalidURL:
            return "invalidURL"
        case .invalidResponse:
            return "invalidResponse"
        case let .invalidData(message):
            if let message {
                return message
            }
        case .decodeError:
            return "decodeError"
        }
        return ""
    }
}

final public class GitHubAPIManager {
    typealias failureClosure = (APIError) -> ()
    static let shared = GitHubAPIManager()
    private let provider = MoyaProvider<GitHubAPI>()
    
    private func JSONResponseDataFormatter(_ data: Data) -> String {
        do {
            let dataAsJSON = try JSONSerialization.jsonObject(with: data)
            let prettyData = try JSONSerialization.data(
                withJSONObject: dataAsJSON,
                options: .prettyPrinted
            )
            return String(data: prettyData, encoding: .utf8) ?? 
            String(data: data, encoding: .utf8) ?? ""
        } catch {
            return String(data: data, encoding: .utf8) ?? ""
        }
    }
    
    func request<ResponseObject: Decodable>(
        api: Any,
        responseObject: ResponseObject.Type,
        onSuccess success: @escaping (ResponseObject) -> (),
        onFailure failure: @escaping (APIError) -> ()
    ) {
        provider.request(api as! GitHubAPI) { result in
            switch result {
            case let .success(response):
                do {
                    let responseObject = try JSONDecoder().decode(
                        responseObject.self,
                        from: response.data
                    )
                    success(responseObject)
                } catch {
                    failure(.decodeError)
                }
            case .failure:
                failure(.invalidResponse)
            }
        }
    }

    /// Github 사용자 검색 API
    static func searchUsers(
        param: UserParameters,
        onSuccess success: @escaping (UserInfo) -> Void,
        onFailure failure: @escaping failureClosure
    ) {
        shared.request(
            api: GitHubAPI.searchUsers(param),
            responseObject: UserInfo.self,
            onSuccess: success,
            onFailure: failure
        )
    }
}
