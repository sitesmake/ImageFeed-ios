//
//  PhotoResult.swift
//  ImageFeed
//
//  Created by alexander on 09.02.2025.
//

import Foundation

struct PhotoResult: Decodable {
    let id: String
    let width: Int
    let height: Int
    let createdAt: String?
    let description: String?
    let urls: UrlsResult
    let likedByUser: Bool
}
