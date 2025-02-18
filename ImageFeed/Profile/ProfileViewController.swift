//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by alexander on 01.12.2024.
//

import UIKit
import Kingfisher

public protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfileViewPresenterProtocol? { get set }
    func setupProfileDetails(name: String, login: String, bio: String)
    func setupAvatar(url: URL)
}

final class ProfileViewController: UIViewController, ProfileViewControllerProtocol {
    private var usernameLabel, profileLabel, textLabel: UILabel?
    private var imageView: UIImageView?
    private var profileImageServiceObserver: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .ypBlack

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

        guard let token = OAuth2Storage.shared.token else {
            print("There is no token")
            return
        }
        print(token)

        presenter?.view = self
        presenter?.updateProfileDetails()
        presenter?.observerProfileImageService()
    }

    var presenter: ProfileViewPresenterProtocol? = {
        return ProfileViewPresenter()
    }()

    func setupProfileDetails(name: String, login: String, bio: String) {
        usernameLabel?.text = name
        profileLabel?.text = login
        textLabel?.text = bio
    }

    func setupAvatar(url: URL) {
        let cache = ImageCache.default
        cache.clearDiskCache()
        let processor = RoundCornerImageProcessor(cornerRadius: 42)

        imageView?.kf.setImage(with: url,
                              placeholder: UIImage(named: "placeholder"),
                              options: [.processor(processor), .transition(.fade(1))])
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
        let alert = UIAlertController(title: "Пока, пока!", message: "Уверены что хотите выйти?", preferredStyle: .alert)

        let yesAction = UIAlertAction(title: "Да", style: .default) { _ in
            OAuth2Storage.shared.clean()
            WebViewViewController.clean()
            ImagesListViewController.clean()

            guard let window = UIApplication.shared.windows.first else { return }
            window.rootViewController = SplashViewController()
            window.makeKeyAndVisible()
        }

        let noAction = UIAlertAction(title: "Нет", style: .default) { _ in
            alert.dismiss(animated: true)
        }

        alert.addAction(yesAction)
        alert.addAction(noAction)
        
        present(alert, animated: true)
    }
}
