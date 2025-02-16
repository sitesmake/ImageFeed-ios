//
//  UrlsResult.swift
//  ImageFeed
//
//  Created by alexander on 09.02.2025.
//

import Foundation

struct UrlsResult: Decodable {
    let full: String
    let regular: String
    let small: String
    let thumb: String
}
