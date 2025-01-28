//
//  ProfileService.swift
//  ImageFeed
//
//  Created by alexander on 28.01.2025.
//

import Foundation

enum ProfileServiceError: Error {
    case invalidRequest
}

final class ProfileService {
    static let shared = ProfileService()
    private init() {}

    private var task: URLSessionTask?
    private var lastToken: String?

    private let urlSession = URLSession.shared
    private(set) var profile: ProfileResult?

    func fetchProfile(_ token: String, completion: @escaping (Result<ProfileResult, Error>) -> Void) {
        assert(Thread.isMainThread)

        guard lastToken != token else {
            completion(.failure(ProfileServiceError.invalidRequest))
            return
        }

        task?.cancel()
        lastToken = token

        guard let request = makeProfileRequest(token: token) else {
            print("Error configure request")
            return
        }

        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            guard let self else { return }
            
            switch result {
            case .success(let profileResult):
                self.profile = profileResult
                completion(.success(profileResult))
            case .failure(let error):
                print("Request error fetching profileResult: \(error)")
                completion(.failure(error))
            }

            self.task = nil
            self.lastToken = nil
        }

        self.task = task
        task.resume()
    }

    private func makeProfileRequest(token: String) -> URLRequest? {
        guard let baseURL = URL(string: "https://api.unsplash.com") else {
            print("Error fetch base URL")
            return nil
        }

        guard let url = URL(
            string: "/me",
            relativeTo: baseURL
        ) else {
            print("Error fetch URL")
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        return request
    }
}
