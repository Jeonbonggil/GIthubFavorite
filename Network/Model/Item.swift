//
//	Item.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation

struct Item: Codable {
    var initial: String = ""        // 초성(즐겨찾기용)
	let username: String		    // 사용자 이름
    let avatarURL: String           // 프로필 이미지 URL
    let htmlURL: String             // 사용자 URL
    var isFavorite: Bool = false    // 즐겨찾기 여부
	    
    enum codingKeys: String, CodingKey {
        case username = "login"
        case avatarURL = "avatar_url"
        case htmlURL = "html_url"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: codingKeys.self)
        username = try values.decode(String.self, forKey: .username)
        avatarURL = try values.decode(String.self, forKey: .avatarURL)
        htmlURL = try values.decode(String.self, forKey: .htmlURL)
    }
}

