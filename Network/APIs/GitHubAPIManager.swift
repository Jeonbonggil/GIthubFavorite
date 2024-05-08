//
//  GitHubAPIManager.swift
//  GithubUserFavorite
//
//  Created by Bonggil Jeon on 5/4/24.
//

import Foundation
import Moya

public enum APIError: Error {
    case invalidResponse(message: String? = nil)
    case underlyingFailure(_ description: String)
    case decodeError
    
    var localizedDescription: String {
        return message()
    }
    
    func message() -> String {
        switch self {
        case .invalidResponse(let message):
            if let message {
                return message
            }
        case .decodeError:
            return "decodeError"
        case .underlyingFailure(let description):
            return description
        }
        return ""
    }
}

final public class GitHubAPIManager {
    typealias failureClosure = (APIError) -> Void
    static let shared = GitHubAPIManager()
    static let maxRetryCount = 3
    private let provider = MoyaProvider<GitHubAPI>()
    private var retryCount = 0
    
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
        onSuccess success: @escaping (ResponseObject) -> Void,
        onFailure failure: @escaping (APIError) -> Void,
        retry: (() -> Void)? = nil
    ) {
        provider.request(api as! GitHubAPI) { [weak self] result in
            guard let self else { return }
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
            case .failure(let error):
                if retryCount < Self.maxRetryCount {
                    retryCount += 1
                    retry?()
                } else {
                    retryCount = 0
                    if let desc = error.errorDescription {
                        failure(.underlyingFailure(desc))
                    }
                }
                failure(.invalidResponse(message: error.errorDescription))
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
