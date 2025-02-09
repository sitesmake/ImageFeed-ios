//
//  Photo.swift
//  ImageFeed
//
//  Created by alexander on 08.02.2025.
//

import Foundation

struct Photo: Codable {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let regularImageURL: String
    let smallImageURL: String
    let isLiked: Bool

    init(_ photoResult: PhotoResult, date: ISO8601DateFormatter) {
        self.id = photoResult.id
        self.size = CGSize(width: photoResult.width, height: photoResult.height)
        self.createdAt = date.date(from: photoResult.createdAt ?? "")
        self.welcomeDescription = photoResult.description
        self.thumbImageURL = photoResult.urls.thumb
        self.largeImageURL = photoResult.urls.full
        self.regularImageURL = photoResult.urls.regular
        self.smallImageURL = photoResult.urls.small
        self.isLiked = photoResult.likedByUser
    }
}
