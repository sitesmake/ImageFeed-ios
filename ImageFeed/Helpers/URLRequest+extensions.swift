//
//  URLRequest+extensions.swift
//  ImageFeed
//
//  Created by alexander on 31.01.2025.
//

import Foundation

extension URLRequest {
    static func makeHTTPRequest(path: String, method: String, queryItems: [URLQueryItem]? = nil) -> URLRequest? {
        guard var url = URL(
            string: path,
            relativeTo: Constants.defaultBaseURL
        ) else {
            print("Error fetch URL")
            return nil
        }

        guard let token = OAuth2Storage.shared.token else {
            print("There is no token")
            return nil
        }

        url.appendQueryItems(queryItems: queryItems)

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        return request
    }
}

extension URL {
    mutating func appendQueryItems(queryItems: [URLQueryItem]?) {
        guard let queryItems = queryItems,
              var urlComponents = URLComponents(string: absoluteString) else { return }

        var currentQueryItems = urlComponents.queryItems ?? []
        currentQueryItems.append(contentsOf: queryItems)
        urlComponents.queryItems = currentQueryItems

        if let newUrl = urlComponents.url {
            self = newUrl
        }
    }
}
