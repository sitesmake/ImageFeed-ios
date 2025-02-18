//
//  ViewController.swift
//  ImageFeed
//
//  Created by alexander on 23.11.2024.
//

import UIKit
import Kingfisher

public protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImagesListPresenterProtocol? { get set }
    func updateTableViewAnimated(oldCount: Int, newCount: Int)
}


final class ImagesListViewController: UIViewController, ImagesListViewControllerProtocol {
    @IBOutlet private var tableView: UITableView!

    private let showSingleImageSegueIdentifier = "ShowSingleImage"

    var presenter: ImagesListPresenterProtocol? = {
        return ImagesListPresenter()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter?.view = self
        setupTableView()
        presenter?.viewDidLoad()
    }

    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }

    func updateTableViewAnimated(oldCount: Int, newCount: Int) {
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }

            guard let photo = presenter?.getPhotoIndex(indexPath.row)?.largeImageURL else { return }
            let largeImageURL = URL(string: photo)
            viewController.image = largeImageURL
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }

    static func clean() {
        let cache = ImageCache.default
        cache.clearMemoryCache()
        cache.clearDiskCache()
        cache.backgroundCleanExpiredDiskCache()
        cache.cleanExpiredMemoryCache()
        cache.clearCache()
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let photosCount = presenter?.photosCount else { return 0 }
        return photosCount
    }

    private func setupCell(_ cell: ImagesListCell, _ indexPath: IndexPath) {
        guard let photo = presenter?.getPhotoIndex(indexPath.row) else { return }
        cell.setupCell(from: photo)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)

        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }

        imageListCell.delegate = self
        setupCell(imageListCell, indexPath)

        return imageListCell
    }
}

extension ImagesListViewController: ImagesListDelegate {
    func imagesListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        presenter?.imageListCellDidTapLike(indexPath.row, cell)
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        presenter?.willDisplay(indexPath.row)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let photo = presenter?.getPhotoIndex(indexPath.row)?.size else { return CGFloat() }

        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = photo.width
        guard imageWidth > 0 else { return 0 }
        let scale = imageViewWidth / imageWidth
        let cellHeight = photo.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
}
