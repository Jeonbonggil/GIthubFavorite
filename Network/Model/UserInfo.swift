//
//	UserInfo.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation

struct UserInfo: Decodable {
	let incomplete_results: Bool
	let items: [Item]
	let total_count: Int
}