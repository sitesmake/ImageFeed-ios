//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by alexander on 01.12.2024.
//

import UIKit

final class ProfileViewController: UIViewController {
    private var usernameLabel, profileLabel, textLabel: UILabel?
    private var imageView: UIImageView?

    override func viewDidLoad() {
        super.viewDidLoad()

        let profileImage = UIImage(named: "avatar")
        let imageView = UIImageView(image: profileImage)
        setupImageView(imageView)

        let usernameLabel = UILabel()
        let profileLabel = UILabel()
        let textLabel = UILabel()

        setupUsernameLabel(usernameLabel)
        setupProfileLabel(profileLabel)
        setupTextLabel(textLabel)

        NSLayoutConstraint.activate([
            usernameLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            usernameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            profileLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            profileLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 8),
            textLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            textLabel.topAnchor.constraint(equalTo: profileLabel.bottomAnchor, constant: 8)
        ])

        let button = UIButton.systemButton(
            with: UIImage(named: "logout_button")!,
            target: self,
            action: #selector(Self.didTapButton)
        )
        button.tintColor = UIColor(named: "logout_button_color")
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20).isActive = true
        button.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true

        let token = OAuth2Storage.shared.token!
        print(token)

        updateProfileDetails()
    }

    private func updateProfileDetails() {
        guard let profile = ProfileService.shared.profile else { return }
        usernameLabel?.text = profile.username
        profileLabel?.text = profile.username
        textLabel?.text = profile.bio
    }

    private func setupImageView(_ imageView: UIImageView) {
        imageView.tintColor = .gray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20).isActive = true
        imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        self.imageView = imageView
    }

    private func setupUsernameLabel(_ label: UILabel) {
        label.text = "Екатерина Новикова"
        label.textColor = .white
        label.font = .systemFont(ofSize: 23.0, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        self.usernameLabel = label
    }

    private func setupProfileLabel(_ label: UILabel) {
        label.text = "@ekaterina_nov"
        label.textColor = UIColor(named: "profile_gray")
        label.font = label.font.withSize(13)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        self.profileLabel = label
    }

    private func setupTextLabel(_ label: UILabel) {
        label.text = "Hello, world!"
        label.textColor = .white
        label.font = label.font.withSize(13)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        self.textLabel = label
    }

    @objc
    private func didTapButton() {
        usernameLabel?.removeFromSuperview()
        usernameLabel = nil

        profileLabel?.removeFromSuperview()
        profileLabel = nil

        textLabel?.removeFromSuperview()
        textLabel = nil

        let logoutImage = UIImage(systemName: "person.crop.circle.fill")
        imageView?.image = logoutImage
    }
}
