//
//  GitHubAPIManager.swift
//  GithubUserFavorite
//
//  Created by Bonggil Jeon on 5/4/24.
//

import Foundation
import Moya

final public class GitHubAPIManager {
    static let shared = GitHubAPIManager()
    private let provider = MoyaProvider<GitHubUsers>()
    
    private func JSONResponseDataFormatter(_ data: Data) -> String {
        do {
            let dataAsJSON = try JSONSerialization.jsonObject(with: data)
            let prettyData = try JSONSerialization.data(
                withJSONObject: dataAsJSON,
                options: .prettyPrinted
            )
            return String(data: prettyData, encoding: .utf8) ?? String(data: data, encoding: .utf8) ?? ""
        } catch {
            return String(data: data, encoding: .utf8) ?? ""
        }
    }
    
    static func searchUsers(
        param: UserParameters,
        completion: @escaping (Result<UserInfo, Error>) -> Void
    ) {
        GitHubAPIManager().provider.request(.searchUsers(param)) { result in
            switch result {
            case let .success(response):
                do {
                    let searchUsersResponse = try JSONDecoder().decode(
                        UserInfo.self,
                        from: response.data
                    )
                    completion(.success(searchUsersResponse))
                } catch {
                    completion(.failure(error))
                }
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}
