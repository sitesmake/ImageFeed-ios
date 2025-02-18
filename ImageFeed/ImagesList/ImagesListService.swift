//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by alexander on 08.02.2025.
//

import Foundation

final class ImagesListService: ImagesListServiceProtocol {
    private (set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private var currentTask: URLSessionTask?
    private let urlSession = URLSession.shared
    static let shared = ImagesListService()
    private let dateFormatter = ISO8601DateFormatter()

    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")

    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)

        guard currentTask == nil else { return } 

        let nextPage = (lastLoadedPage ?? 0) + 1

        guard let request = makeRequest(page: nextPage) else {
            print("запрос не удался")
            return
        }
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let photoResults):
                    let last_page_number = (self.lastLoadedPage ?? 0) + 1
                    self.lastLoadedPage = last_page_number

                    let newPhotos = photoResults.map { Photo($0, date: self.dateFormatter) }

                    //as unsplash api duplicates last photo & first photo on next page - skips them to not duplicate on screen
                    if (last_page_number > 1) {
                        let resultSize = newPhotos.count
                        self.photos.append(contentsOf: newPhotos[1..<resultSize])
                    } else {
                        self.photos.append(contentsOf: newPhotos)
                    }

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

    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        if currentTask != nil {
            currentTask?.cancel()
        }

        let request = URLRequest.makeHTTPRequest(path: "/photos/\(photoId)/like", method: isLike ? "POST" : "DELETE")
        guard let request = request else {
            print("Error making request")
            return
        }

        let task = urlSession.objectTask(for: request) { (result: Result<PhotoLike, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                        let photo = self.photos[index]
                        let newPhotoResult = PhotoResult(id: photo.id,
                                                         width: Int(photo.size.width),
                                                         height: Int(photo.size.height),
                                                         createdAt: photo.createdAt?.description,
                                                         description: photo.welcomeDescription,
                                                         urls: UrlsResult(full: photo.largeImageURL,
                                                                          regular: photo.regularImageURL,
                                                                          small: photo.smallImageURL,
                                                                          thumb: photo.thumbImageURL),
                                                         likedByUser: !photo.isLiked)
                        let newPhoto = Photo(newPhotoResult, date: self.dateFormatter)
                        self.photos[index] = newPhoto
                        completion(.success(()))
                    }

                case .failure(let error):
                    print("error like: \(error)")
                }
            }
        }
        self.currentTask = task
        task.resume()
    }
}
