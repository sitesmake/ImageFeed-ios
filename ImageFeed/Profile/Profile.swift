//
//  Profile.swift
//  ImageFeed
//
//  Created by alexander on 25.01.2025.
//

import Foundation

struct Profile: Decodable {
    let username: String?
    let name: String?
    let loginName: String?
    let bio: String?

    init(ProfileResult: ProfileResult) {
        self.username = ProfileResult.username
        self.name = ProfileResult.firstName + " " + (ProfileResult.lastName ?? "")
        self.loginName = "@" + (ProfileResult.username)
        self.bio = ProfileResult.bio
    }
}


