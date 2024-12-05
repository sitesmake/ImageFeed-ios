//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by alexander on 01.12.2024.
//

import UIKit

final class SingleImageViewController: UIViewController {
    var image: UIImage? {
        didSet {
            guard isViewLoaded else { return }
            imageView.image = image
        }
    }

    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
    }

    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
}
