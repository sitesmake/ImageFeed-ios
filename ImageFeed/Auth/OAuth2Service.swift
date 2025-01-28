//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by alexander on 18.12.2024.
//

import Foundation

enum AuthServiceError: Error {
    case invalidRequest
}

final class OAuth2Service {
    static let shared = OAuth2Service()
    private init() {}
    private let storage = OAuth2Storage.shared

    private var task: URLSessionTask?
    private var lastCode: String?

    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)

        guard lastCode != code else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }

        task?.cancel()
        lastCode = code

        guard let request = makeOAuthTokenRequest(code: code) else {
            print("Error configure request")
            return
        }

        let task = object(for: request) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let body):
                let authToken = body.accessToken
                self.storage.token = authToken
                completion(.success(authToken))
            case .failure(let error):
                print("Request error fetching token: \(error)")
                completion(.failure(error))
            }

            self.task = nil
            self.lastCode = nil
        }

        self.task = task
        task.resume()
    }

    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard let baseURL = URL(string: "https://unsplash.com") else {
            print("Error fetch base URL")
            return nil
        }

        guard let url = URL(
            string: "/oauth/token"
            + "?client_id=\(Constants.accessKey)"
            + "&&client_secret=\(Constants.secretKey)"
            + "&&redirect_uri=\(Constants.redirectURI)"
            + "&&code=\(code)"
            + "&&grant_type=authorization_code",
            relativeTo: baseURL
        ) else {
            print("Error fetch URL")
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        return request
    }

    private func object(
        for request: URLRequest,
        completion: @escaping (Result<OAuth2ResponseBody, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        return URLSession.shared.data(for: request) { (result: Result<Data, Error>) in
            let response = result.flatMap { data -> Result<OAuth2ResponseBody, Error> in
                Result { try decoder.decode(OAuth2ResponseBody.self, from: data) }
            }
            completion(response)
        }
    }
}
