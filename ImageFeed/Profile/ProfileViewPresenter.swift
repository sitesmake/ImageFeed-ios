//
//  ProfileViewPresenter.swift
//  ImageFeed
//
//  Created by alexander on 18.02.2025.
//

import Foundation

public protocol ProfileViewPresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
    func updateProfileDetails()
    func updateAvatar()
    func observerProfileImageService()
}

final class ProfileViewPresenter: ProfileViewPresenterProtocol {
    private let profileService: ProfileServiceProtocol
    private let profileImageService: ProfileImageServiceProtocol
    
    weak var view: ProfileViewControllerProtocol?
    private var profileImageServiceObserver: NSObjectProtocol?

    init(
        profileService: ProfileServiceProtocol = ProfileService.shared,
        profileImageService: ProfileImageServiceProtocol = ProfileImageService.shared
    ) {
        self.profileService = profileService
        self.profileImageService = profileImageService
    }


    func updateProfileDetails() {
        guard let profile = profileService.profile else { return }

        view?.setupProfileDetails(
            name: profile.name ?? "",
            login: profile.loginName ?? "",
            bio: profile.bio ?? ""
        )
        
        updateAvatar()
    }

    func updateAvatar() {
        guard
            let profileImageURL = profileImageService.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }

        view?.setupAvatar(url: url)
    }

    func observerProfileImageService() {
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }

        updateAvatar()
    }
}
