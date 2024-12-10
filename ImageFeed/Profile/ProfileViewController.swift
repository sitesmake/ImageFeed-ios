//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by alexander on 01.12.2024.
//

import UIKit

final class ProfileViewController: UIViewController {
    private var label, label2, label3: UILabel?
    private var imageView: UIImageView?

    override func viewDidLoad() {
        super.viewDidLoad()

        let profileImage = UIImage(named: "avatar")
        let imageView = UIImageView(image: profileImage)
        imageView.tintColor = .gray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20).isActive = true
        imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        self.imageView = imageView

        let label = UILabel()
        let label2 = UILabel()
        let label3 = UILabel()

        label.text = "Екатерина Новикова"
        label.textColor = .white
        label.font = label.font.withSize(23)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        self.label = label

        label2.text = "@ekaterina_nov"
        label2.textColor = UIColor(named: "profile_gray")
        label2.font = label.font.withSize(13)
        label2.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label2)
        self.label2 = label2

        label3.text = "Hello, world!"
        label3.textColor = .white
        label3.font = label.font.withSize(13)
        label3.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label3)
        self.label3 = label3

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            label2.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            label2.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 8),
            label3.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            label3.topAnchor.constraint(equalTo: label2.bottomAnchor, constant: 8)
        ])


        let button = UIButton.systemButton(
            with: UIImage(systemName: "ipad.and.arrow.forward")!,
            target: self,
            action: #selector(Self.didTapButton)
        )
        button.tintColor = .red
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20).isActive = true
        button.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
    }

    @objc
    private func didTapButton() {
        label?.removeFromSuperview()
        label = nil

        label2?.removeFromSuperview()
        label2 = nil

        label3?.removeFromSuperview()
        label3 = nil

        let logoutImage = UIImage(systemName: "person.crop.circle.fill")
        imageView?.image = logoutImage
    }
}
