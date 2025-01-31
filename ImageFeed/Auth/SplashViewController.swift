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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let token = oauth2TokenStorage.token {
            fetchProfile(token)
        } else {
            performSegue(withIdentifier: showAuthenticationScreenSegue, sender: nil)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }

    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
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
                guard let username = profile.username else {
                    print ("!!! There is no username")
                    return
                }
                print("ProfileImageService.shared.fetchProfileImageURL(username: \(username))")
                ProfileImageService.shared.fetchProfileImageURL(username: username) { _ in }
                self.switchToTabBarController()
                UIBlockingProgressHUD.dismiss()

            case .failure:
                // TODO [Sprint 11] Покажите ошибку получения профиля
                print("TODO [Sprint 11] Покажите ошибку получения профиля")
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
                    break
                }
            }
        }
    }
}


// MARK: - Check authorization
extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAuthenticationScreenSegue {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
            else {
                fatalError("Failed to prepare for \(showAuthenticationScreenSegue)")
            }

            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension SplashViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
}

