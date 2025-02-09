//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by alexander on 27.11.2024.
//

import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    weak var delegate: ImagesListDelegate?

    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var cellLabel: UILabel!
    @IBOutlet weak var cellButton: UIButton!

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()

    override func prepareForReuse() {
        cellImage.kf.cancelDownloadTask()
    }

    func setupCell(from photo: Photo) {

        let url = URL(string: photo.smallImageURL)
        cellImage.kf.indicatorType = .activity
        cellImage.kf.setImage(with: url, placeholder: UIImage(named: "ImagePlaceholder")) { result in
            switch result {
            case .success(let image):
                self.cellImage.contentMode = .scaleAspectFill
                self.cellImage.image = image.image
            case .failure(let error):
                print("Error loading image: \(error)")
                self.cellImage.image = UIImage(named: "ImagePlaceholder")
            }
        }
        cellLabel.text = dateFormatter.string(from: photo.createdAt ?? Date())
    }
}
