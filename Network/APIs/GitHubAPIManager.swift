//
//  GitHubAPIManager.swift
//  GithubUserFavorite
//
//  Created by Bonggil Jeon on 5/4/24.
//

import Foundation
import Moya

public enum APIError: Error {
    case requestError(_ description: String)
    case serverError(_ description: String)
    case decodeError(_ description: String)
    
    var localizedDescription: String {
        return message()
    }
    
    func message() -> String {
        switch self {
        case .requestError(let description):
            return "requestError: \(description)"
        case .decodeError(let description):
            return "decodeError: \(description)"
        case .serverError(let description):
            return "serverError: \(description)"
        }
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
    /// API 요청
    func requestAPI<ResponseObject: Decodable>(api: TargetType) async throws -> ResponseObject {
        let result = await provider.request(api)
        do {
            let response = try result.get()
            let object = try response.map(ResponseObject.self)
            switch response.statusCode {
            case 200...299:
                return object
            case 400...499:
                throw APIError.requestError(response.description)
            case 500...599:
                throw APIError.serverError(response.description)
            default:
                throw APIError.decodeError(response.description)
            }
        } catch {
            throw APIError.decodeError(try result.get().description)
        }
    }
    /// Github 사용자 검색 API
    static func searchUsers(param: UserParameters) async throws -> UserInfo {
        try await shared.requestAPI(api: GitHubAPI.searchUsers(param))
    }
}

extension MoyaProvider {
    func request(_ target: TargetType) async -> Result<Response, MoyaError> {
        await withCheckedContinuation { continuation in
            self.request(target as! Target) { result in
                continuation.resume(returning: result)
            }
        }
    }
}
