//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by alexander on 31.01.2025.
//

import Foundation

final class ProfileImageService {
    
    private struct UserResult: Codable {
        let profileImage: ProfileImage
    }
    
    private struct ProfileImage: Codable {
        let small: String
        let medium: String
        let large: String
    }

    static let shared = ProfileImageService()
    private init() {}

    private var task: URLSessionTask?
    private(set) var avatarURL: String?

    private let urlSession = URLSession.shared
    private let oauth2TokenStorage = OAuth2Storage.shared

    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")

    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void ) {
        assert(Thread.isMainThread)
        task?.cancel()

        guard let request = URLRequest.makeHTTPRequest(path: "/users/\(username)", method: "GET") else {
            assertionFailure("Failed to make HTTP request")
            return
        }

        let task = urlSession.objectTask(for: request) { [weak self] (result:Result<UserResult, Error>) in
            guard let self else { return }
            
            switch result {
            case .success(let user):
                completion(.success(user.profileImage.large))
                NotificationCenter.default.post(
                    name: ProfileImageService.didChangeNotification,
                    object: self,
                    userInfo: ["URL": user.profileImage.large]
                )
                self.avatarURL = user.profileImage.large
            case .failure(let error):
                completion(.failure(error))
            }
            self.task = nil
        }
        self.task = task
        task.resume()
    }
}
