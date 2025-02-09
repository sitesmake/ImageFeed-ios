//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by alexander on 08.02.2025.
//

import Foundation

final class ImagesListService {
    private (set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private var currentTask: URLSessionTask?
    private let urlSession = URLSession.shared
    static let shared = ImagesListService()

    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")

    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)

        guard currentTask == nil else { return }

        let nextPage = lastLoadedPage == nil ? 1 : lastLoadedPage! + 1

        guard let request = makeRequest(page: nextPage) else {
            print("запрос не удался")
            return
        }
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let photoResults):
                    if self.lastLoadedPage == nil {
                        self.lastLoadedPage = 1
                    } else {
                        self.lastLoadedPage! += 1
                    }

                    let newPhotos = photoResults.map { Photo($0, date: ISO8601DateFormatter()) }
                    self.photos.append(contentsOf: newPhotos)

                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification,
                                                    object: nil)

                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            self.currentTask = nil
        }
        self.currentTask = task
        task.resume()
    }

    private func makeRequest(page: Int) -> URLRequest? {
        let queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "10")
        ]
        return URLRequest.makeHTTPRequest(path: "/photos", method: "GET", queryItems: queryItems)
    }
}
