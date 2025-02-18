@testable import ImageFeed
import XCTest

final class ImageListTests: XCTestCase {

    func testFetchPhotosNextPage() {
        let imageListServiceTestModel = ImageListServiceTestModel()
        let presenter = ImagesListPresenter(imagesListService: imageListServiceTestModel)

        presenter.viewDidLoad()

        XCTAssertEqual(imageListServiceTestModel.photos.count, 1)
    }

    func testUpdateTableView() {
        let ImageListServiceTestModel = ImageListServiceTestModel()
        let view = ImageListViewControllerSpy()
        let presenter = ImagesListPresenter(imagesListService: ImageListServiceTestModel)
        presenter.view = view

        ImageListServiceTestModel.fetchPhotosNextPage()
        presenter.updateTableView()

        XCTAssertTrue(view.updateTableViewAnimatedCalled == true)
    }

    func testWillDisplay() {
        let ImageListServiceTestModel = ImageListServiceTestModel()
        let view = ImageListViewControllerSpy()
        let presenter = ImagesListPresenter(imagesListService: ImageListServiceTestModel)
        presenter.view = view

        ImageListServiceTestModel.fetchPhotosNextPage()
        presenter.updateTableView()
        presenter.willDisplay(0)

        XCTAssertEqual(ImageListServiceTestModel.photos.count, 2)
    }
}

private let dateFormatter = ISO8601DateFormatter()
private let photo = Photo(PhotoResult(id: "testPhoto",
                                      width: 200,
                                      height: 200,
                                      createdAt: "2025-02-18T01:12:23",
                                      description: "test photo",
                                      urls: UrlsResult(full: "full",
                                                       regular: "regular",
                                                       small: "small",
                                                       thumb: "thumb"),
                                      likedByUser: false),
                          date: dateFormatter)

private final class ImageListServiceTestModel: ImagesListServiceProtocol {
    var photos: [ImageFeed.Photo] = []
    func fetchPhotosNextPage() { photos.append(photo) }
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {}
}

final class ImageListPresenterSpy: ImagesListPresenterProtocol {
    var view: ImageFeed.ImagesListViewControllerProtocol?
    var photosCount: Int = 0

    var viewDidLoadCalled = false
    var getPhotoIndexCalled = false
    var tableViewUpdatedCalled = false
    var willDisplayCalled = false
    var imageListCellDidTapLikeCalled = false

    func getPhotoIndex(_ index: Int) -> ImageFeed.Photo? {
        getPhotoIndexCalled = true
        return nil
    }

    func viewDidLoad() {
        viewDidLoadCalled = true
    }

    func updateTableView() {
        tableViewUpdatedCalled = true
    }

    func willDisplay(_ indexPath: Int) {
        willDisplayCalled = true
    }

    func imageListCellDidTapLike(_ index: Int, _ cell: ImageFeed.ImagesListCell) {
        imageListCellDidTapLikeCalled = true
    }
}

final class ImageListViewControllerSpy : ImagesListViewControllerProtocol {
    var presenter: ImageFeed.ImagesListPresenterProtocol?
    var updateTableViewAnimatedCalled = false

    func updateTableViewAnimated(oldCount: Int, newCount: Int) {
        updateTableViewAnimatedCalled = true
    }
}
