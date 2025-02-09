//
//  ImagesListDelegate.swift
//  ImageFeed
//
//  Created by alexander on 09.02.2025.
//

import Foundation

protocol ImagesListDelegate: AnyObject {
    func imagesListCellDidTapLike(_ cell: ImagesListCell)
}
