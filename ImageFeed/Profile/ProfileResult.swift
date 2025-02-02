//
//  ProfileResult.swift
//  ImageFeed
//
//  Created by alexander on 25.01.2025.
//

import Foundation

struct ProfileResult: Decodable {
    let username: String
    let firstName: String
    let lastName: String?
    let bio: String?
}
