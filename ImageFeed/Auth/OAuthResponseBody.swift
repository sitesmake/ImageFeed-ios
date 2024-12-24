//
//  OAuthResponseBody.swift
//  ImageFeed
//
//  Created by alexander on 20.12.2024.
//

import Foundation

struct OAuth2ResponseBody: Decodable {
    let accessToken: String
    let tokenType: String
    let scope: String
    let createdAt: Int

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case scope
        case createdAt = "created_at"
    }
}
