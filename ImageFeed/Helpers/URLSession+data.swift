//
//  URLSession+data.swift
//  ImageFeed
//
//  Created by alexander on 20.12.2024.
//

import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError(Error)
}

extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }

        let task = dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200 ..< 300 ~= statusCode {
                    fulfillCompletionOnTheMainThread(.success(data))
                } else {
                    print("Response error status: \(statusCode)")
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                }
            } else if let error = error {
                print("Request error \(error)")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
            } else if let error = error {
                print("Session error")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError(error)))
            }
        })

        return task
    }

    func objectTask<DecodingType: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<DecodingType, Error>) -> Void
    ) -> URLSessionTask {
        let task = dataTask(with: request) { data, response, error in

            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.urlSessionError(error)))
                }
            }

            if let response = response as? HTTPURLResponse {
                if !(200..<300 ~= response.statusCode) {
                    DispatchQueue.main.async {
                        completion(.failure(NetworkError.httpStatusCode(response.statusCode)))
                    }
                }
            }

            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let result = try decoder.decode(DecodingType.self, from: data)

                    DispatchQueue.main.async {
                        completion(.success(result))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(NetworkError.urlSessionError(error)))
                    }
                }
            }
        }
        return task
    }
}
