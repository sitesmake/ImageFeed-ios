@testable import ImageFeed
import XCTest

final class ProfileTests: XCTestCase {

    private struct ProfileServiceStub: ProfileServiceProtocol {
        var profile: ImageFeed.Profile? = Profile(ProfileResult: ProfileResult(username: "test", firstName: "test", lastName: "test", bio: "test"))

        func fetchProfile(_ token: String, completion: @escaping (Result<ImageFeed.ProfileResult, Error>) -> Void) {}
    }

    private struct ProfileImageServiceStub: ProfileImageServiceProtocol {
        var avatarURL: String? = "https://api.unsplash.com"

        func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {}
    }

    func testUpdataProfileDetailsCalls() {
        let viewController = ProfileViewController()
        let spyPresenter = ProfileViewPresentSpy()
        viewController.presenter = spyPresenter
        spyPresenter.view = viewController

        _ = viewController.view

        XCTAssertTrue(spyPresenter.updateProfileDetailsCalled)
    }

    func testViewControllerProfileDetailsCalls() {
        let viewController = ProfileViewControllerSpy()
        let profileServiceStub = ProfileServiceStub()
        let profileImageServiceStub = ProfileImageServiceStub()
        let presenter = ProfileViewPresenter(profileService: profileServiceStub,
                                             profileImageService: profileImageServiceStub)
        viewController.presenter = presenter
        presenter.view = viewController

        presenter.updateProfileDetails()

        XCTAssertTrue(viewController.setupProfileDetailsCalled)
        XCTAssertTrue(viewController.setupAvatarCalled)
    }
}

final class ProfileViewPresentSpy: ProfileViewPresenterProtocol {
    var view: ImageFeed.ProfileViewControllerProtocol?

    var updateAvatarCalled = false
    var updateProfileDetailsCalled = false

    func updateProfileDetails() {
        updateProfileDetailsCalled = true
    }

    func updateAvatar() {
        updateAvatarCalled = true
    }

    func observerProfileImageService() {
    }

}

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: ImageFeed.ProfileViewPresenterProtocol?
    var setupProfileDetailsCalled = false
    var setupAvatarCalled = false
    func setupProfileDetails(name: String, login: String, bio: String) {
        setupProfileDetailsCalled = true
    }

    func setupAvatar(url: URL) {
        setupAvatarCalled = true
    }
}
