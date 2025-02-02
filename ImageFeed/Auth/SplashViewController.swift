//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by alexander on 20.12.2024.
//

import UIKit

final class SplashViewController: UIViewController {
    private let showAuthenticationScreenSegue = "AuthenticationFlow"

    private let oauth2Service = OAuth2Service.shared
    private let oauth2TokenStorage = OAuth2Storage.shared
    private let profileService = ProfileService.shared

    private var splashImage: UIImageView = {
        let image = UIImage(named: "splashScreenLogo")
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        
        view.addSubview(splashImage)

        NSLayoutConstraint.activate([
            splashImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            splashImage.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let token = oauth2TokenStorage.token {
            fetchProfile(token)
        } else {
            switchToAuthViewController()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }

    private func switchToAuthViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let authViewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else { return }
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen

        present(authViewController, animated: true)
    }

    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }

    private func showAlert() {
        let alert = UIAlertController(
            title: "Что то пошло не так",
            message: "Не удалось войти в систему",
            preferredStyle: .alert
        )
        let action = UIAlertAction(title: "Ок", style: .cancel) { [weak self] _ in
            guard let self else { return }
            switchToAuthViewController()
        }
        alert.addAction(action)
        present(alert, animated: true)
    }
}

// MARK: - splash screen
extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)

        guard let token = oauth2TokenStorage.token else {
            return
        }

        fetchProfile(token)
    }

    private func fetchProfile(_ token: String) {
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()

            guard let self = self else { return }

            switch result {
            case .success(let profile):
                ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { _ in }
                self.switchToTabBarController()
                UIBlockingProgressHUD.dismiss()

            case .failure:
                print("Error fetch profile")
                showAlert()
                break
            }
        }
    }

    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        UIBlockingProgressHUD.show()
        oauth2Service.fetchOAuthToken(code) { [weak self] result in
            self?.dismiss(animated: true) {
                UIBlockingProgressHUD.dismiss()
                switch result {
                case .success:
                    self?.switchToTabBarController()
                case .failure:
                    print("Error fetch OAuth token")
                    self?.showAlert()
                    break
                }
            }
        }
    }
}

extension SplashViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
}

