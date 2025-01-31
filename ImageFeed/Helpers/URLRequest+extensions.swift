//
//  URLRequest+extensions.swift
//  ImageFeed
//
//  Created by alexander on 31.01.2025.
//

import Foundation

extension URLRequest {
    static func makeHTTPRequest(path: String, method: String) -> URLRequest? {
        guard let baseURL = URL(string: "https://api.unsplash.com") else {
            print("Error fetch base URL")
            return nil
        }

        guard let url = URL(
            string: path,
            relativeTo: baseURL
        ) else {
            print("Error fetch URL")
            return nil
        }

        guard let token = OAuth2Storage.shared.token else {
            print("There is no token")
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        return request
    }
}
