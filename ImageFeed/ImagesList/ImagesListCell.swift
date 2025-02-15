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

    @IBOutlet private weak var cellButton: UIButton! //lilke
    @IBOutlet private weak var cellLabel: UILabel! //date
    @IBOutlet private weak var cellImage: UIImageView! //image
    
    @IBAction private func likeButtonClicked(_ sender: UIButton) {
        delegate?.imagesListCellDidTapLike(self)
    }

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
        cellImage.kf.setImage(with: url, placeholder: UIImage(named: "ImagePlaceholder")) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let image):
                self.cellImage.contentMode = .scaleAspectFill
                self.cellImage.image = image.image
            case .failure(let error):
                print("Error loading image: \(error)")
                self.cellImage.image = UIImage(named: "ImagePlaceholder")
            }
        }
        setIsLiked(isLiked: photo.isLiked)
        cellLabel.text = dateFormatter.string(from: photo.createdAt ?? Date())
    }

    func setIsLiked(isLiked: Bool) {
        let likeImage = isLiked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off")
        cellButton.setImage(likeImage, for: .normal)
    }
}
