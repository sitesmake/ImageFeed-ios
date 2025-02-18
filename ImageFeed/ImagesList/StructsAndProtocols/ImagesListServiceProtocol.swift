//
//  ImagesListServiceProtocol.swift
//  ImageFeed
//
//  Created by alexander on 18.02.2025.
//

import Foundation

protocol ImagesListServiceProtocol {
    var photos: [Photo] { get }
    func fetchPhotosNextPage()
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void)
}
