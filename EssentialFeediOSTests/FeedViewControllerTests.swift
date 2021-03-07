//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by ShivaRamReddy on 03/03/21.
//

import Foundation
import XCTest
import EssentialFeed
import EssentialFeediOS

class FeedViewControllerTests: XCTestCase {
 
    func test_loadFeedAction_requestFeedFromLoader() {
        
        let (sut, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadedCellCount, 0)
    
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadedCellCount, 1)
        
        sut.simulateUserIntiatedReload()
        
        XCTAssertEqual(loader.loadedCellCount, 2)
        
        sut.simulateUserIntiatedReload()
        
        XCTAssertEqual(loader.loadedCellCount, 3)
    }
    
    func test_loadFeedActions_showsLoadingIndicator() {
        
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.isShowLoadingIndicator, true)
    
        loader.successfullyCompletedLodinngFeed(at: 0)
        
        XCTAssertEqual(sut.isShowLoadingIndicator, false)
        
        sut.simulateUserIntiatedReload()

        XCTAssertEqual(sut.isShowLoadingIndicator, true)
   
        loader.failedToCompleteLoadingFed(with: anyNSError(), at: 1)
        
        XCTAssertEqual(sut.isShowLoadingIndicator, false)
    }
    
    func test_loadFeedCompletion_rendersSuccessfullyLoadedFeed() {
        
        let image0 = makeImage(description: "a description", location: "a location")
        let image1 = makeImage(description: nil, location: "another location")
        let image2 = makeImage(description: "another description", location: nil)
        let image3 = makeImage(description: nil, location: nil)
        
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        assertThat(sut, isRendering: [])
        
        loader.successfullyCompletedLodinngFeed(with: [image0], at: 0)
        assertThat(sut, isRendering: [image0])
        
        sut.simulateUserIntiatedReload()
        loader.successfullyCompletedLodinngFeed(with: [image0, image1, image2, image3], at: 1)
        assertThat(sut, isRendering: [image0, image1, image2, image3])
    }
    
    func test_feedLoadCompletion_doesNotAlterCurrentRenderState() {
        
        
        let image0 = makeImage(description: "a description", location: "a location")
        
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        assertThat(sut, isRendering: [])
        
        loader.successfullyCompletedLodinngFeed(with: [image0], at: 0)
        assertThat(sut, isRendering: [image0])
        
        sut.simulateUserIntiatedReload()
        loader.failedToCompleteLoadingFed(with: anyNSError(), at: 1)
        assertThat(sut, isRendering: [image0])
    }
    
    func test_feedImageView_loadsImageUrlWhenViewIsVisible() {
        
        let image0 = makeImage(description: "a description", location: "a location")
        let image1 = makeImage(description: nil, location: "another location")
        
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        loader.successfullyCompletedLodinngFeed(with: [image0, image1], at: 0)
        
        XCTAssertEqual(loader.loadedImageUrl.count, 0)
        
        sut.simulateFeedImageViewLoading(at: 0)
        
        XCTAssertEqual(loader.loadedImageUrl.count, 1)
        
        sut.simulateFeedImageViewLoading(at: 1)
        
        XCTAssertEqual(loader.loadedImageUrl.count, 2)
    }
    
    func test_feedImageView_cacelsImageUrlWhenViewIsNotVisible() {
        
        let image0 = makeImage(description: "a description", location: "a location")
        let image1 = makeImage(description: nil, location: "another location")
        
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        loader.successfullyCompletedLodinngFeed(with: [image0, image1], at: 0)
        
        XCTAssertEqual(loader.cancelledloadedImageUrl.count, 0)
        
        sut.simulateFeedImageViewIsNotVisible(at: 0)
        
        XCTAssertEqual(loader.cancelledloadedImageUrl.count, 1)
        
        sut.simulateFeedImageViewIsNotVisible(at: 1)
        
        XCTAssertEqual(loader.cancelledloadedImageUrl.count, 2)
    }
    
    func test_feedImageView_showsLoadingIndicatorWhenImageIsLoading() {
        
        let image0 = makeImage(description: "a description", location: "a location")
        let image1 = makeImage(description: nil, location: "another location")
        
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        loader.successfullyCompletedLodinngFeed(with: [image0, image1], at: 0)
        
        let view0 = sut.simulateFeedImageViewLoading(at: 0)
            
        let view1 = sut.simulateFeedImageViewLoading(at: 1)
        
        XCTAssertEqual(view0.isShowingImageLoadingIndicator, true, "when image is not yet loaded")
        XCTAssertEqual(view1.isShowingImageLoadingIndicator, true, "when image is not yet loaded")
        
        loader.successfullyCompleteLoadingImage(at: 0)
        
        XCTAssertEqual(view0.isShowingImageLoadingIndicator, false, "when image is loaded")
        XCTAssertEqual(view1.isShowingImageLoadingIndicator, true, "when image is not yet loaded")
        
        loader.failedToCompleteLoadingImage(at: 1)
        
        XCTAssertEqual(view0.isShowingImageLoadingIndicator, false, "when image is loaded")
        XCTAssertEqual(view1.isShowingImageLoadingIndicator, false, "when image is loaded")
    }
    
    func test_feedImageView_rendersLoadedImage() {
        
        let image0 = makeImage(description: "a description", location: "a location")
        let image1 = makeImage(description: nil, location: "another location")
        
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        loader.successfullyCompletedLodinngFeed(with: [image0, image1], at: 0)
        
        let view0 = sut.simulateFeedImageViewLoading(at: 0)
        let view1 = sut.simulateFeedImageViewLoading(at: 1)
        
        XCTAssertEqual(view0.renderedImage, .none, "when image is not yet loaded")
        XCTAssertEqual(view1.renderedImage, .none, "when image is not yet loaded")
        
        let imageData0 = UIImage.make(withColor: .red).pngData()!
        loader.successfullyCompleteLoadingImage(at: 0, with: imageData0)
        
        XCTAssertEqual(view0.renderedImage, imageData0, "when image is loaded with correct data")
        XCTAssertEqual(view1.renderedImage, .none, "when image is not yet loaded")
        
        let imageData1 = UIImage.make(withColor: .blue).pngData()!
        loader.successfullyCompleteLoadingImage(at: 1, with: imageData1)
        
        XCTAssertEqual(view0.renderedImage, imageData0, "when image is loaded")
        XCTAssertEqual(view1.renderedImage, imageData1, "when image is loaded")
    }
    
    //MARK:- LOADERSPY
    class LoaderSpy: FeedLoader, FeedImageLoader {
        
        var loadedCellCount: Int   {
            
            return completions.count
        }
        
        private(set) var completions = [(LoadFeedResult) -> Void]()
        
        
        
        func load(completion: @escaping (LoadFeedResult) -> Void) {
            
            completions.append(completion)
        }
        
        func successfullyCompletedLodinngFeed(with feedImage: [FeedImage] = [], at index: Int) {
            
            completions[index](.success(feedImage))
        }
        
        func failedToCompleteLoadingFed(with error: NSError, at index: Int) {
            
            completions[index](.failure(error))
        }
        
        //MARK:-  FEEDIMAGELOADER
        
        private(set) var imageLoadingCompletion = [(url: URL, completion: (FeedImageLoader.Result) -> Void)]()
        
        var loadedImageUrl: [URL] {
            
            imageLoadingCompletion.map { $0.url }
        }
        
        private(set) var cancelledloadedImageUrl = [URL]()
        
        private struct TaskSpy: FeedImageTaskLoader {
            
            var cancelCallBack: () -> Void
            
            func cancel() {
                
                cancelCallBack()
            }
        }
        
        func loadImage(with url: URL, completion: @escaping (FeedImageLoader.Result) -> Void) -> FeedImageTaskLoader {
            
            imageLoadingCompletion.append((url,completion))
            
            return TaskSpy { [weak self] in
                
                self?.cancelledloadedImageUrl.append(url)
            }
        }
        
        
        func successfullyCompleteLoadingImage(at index: Int, with imageData: Data = Data()) {
            
            imageLoadingCompletion[index].completion(.success(imageData))
        }
        
        func failedToCompleteLoadingImage(at index: Int) {
            
            let error = NSError(domain: "erro", code: 100, userInfo: nil)
            imageLoadingCompletion[index].completion(.failure(error))
        }
    }
    
    //MARK: Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
        
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader, imageLoader: loader)
        
        trackMemoryLeak(loader,file: file,line: line)
        trackMemoryLeak(sut,file: file,line: line)
        
        return (sut, loader)
    }
    
    private func anyNSError() -> NSError {
        
        NSError(domain: "any error", code: 0, userInfo: nil)
    }
    
    private func makeImage(description: String? = nil, location: String? = nil, url: URL = URL(string: "http://any-url.com")!) -> FeedImage {
        return FeedImage(id: UUID(), description: description, location: location, imageURL: url)
    }
    
    private func assertThat(_ sut: FeedViewController, isRendering feed: [FeedImage], file: StaticString = #file, line: UInt = #line) {
        guard sut.numberOfRenderedRows() == feed.count else {
            return XCTFail("Expected \(feed.count) images, got \(sut.numberOfRenderedRows()) instead.", file: file, line: line)
        }
        
        feed.enumerated().forEach { index, image in
            assertThat(sut, hasViewConfiguredFor: image, at: index, file: file, line: line)
        }
    }
    
    private func assertThat(_ sut: FeedViewController, hasViewConfiguredFor image: FeedImage, at index: Int, file: StaticString = #file, line: UInt = #line) {
        let view = sut.feedImageView(at: index)
        
        guard let cell = view as? FeedImageCell else {
            return XCTFail("Expected \(FeedImageCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
        }
        
        let shouldLocationBeVisible = (image.location != nil)
        XCTAssertEqual(cell.isShowingLocation, shouldLocationBeVisible, "Expected `isShowingLocation` to be \(shouldLocationBeVisible) for image view at index (\(index))", file: file, line: line)
        
        XCTAssertEqual(cell.locationText, image.location, "Expected location text to be \(String(describing: image.location)) for image  view at index (\(index))", file: file, line: line)
        
        XCTAssertEqual(cell.descriptionText, image.description, "Expected description text to be \(String(describing: image.description)) for image view at index (\(index)", file: file, line: line)
    }
}

extension UIRefreshControl {
    
    func simulatePullToRefresh() {
        
        self.allTargets.forEach({ (target) in
            
            self.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach({
                
                (target as NSObject).perform(Selector($0))
            })
        })
    }
}

private extension FeedViewController {
    
    func simulateUserIntiatedReload() {
        
        refreshControl?.simulatePullToRefresh()
    }
    
    var isShowLoadingIndicator: Bool {
        
        refreshControl?.isRefreshing ?? false
    }
    
    var feedSection: Int {
        
        0
    }
    
    func numberOfRenderedRows() -> Int {
        
        tableView.numberOfRows(inSection: feedSection)
    }
    
    func feedImageView(at index: Int) -> UITableViewCell? {
        
        let ds = tableView.dataSource
        let index = IndexPath(row: index, section: feedSection)
        return ds?.tableView(tableView, cellForRowAt: index)
    }
    
    @discardableResult
    func simulateFeedImageViewLoading(at index: Int) -> FeedImageCell {
        
        let view = feedImageView(at: index) as! FeedImageCell
        return view
    }
    
    func simulateFeedImageViewIsNotVisible(at index: Int) {
        
        let view = simulateFeedImageViewLoading(at: index)
        
        let delegate = tableView.delegate
        delegate?.tableView?(tableView, didEndDisplaying: view, forRowAt:  IndexPath(row: index, section: feedSection))
    }
}


private extension FeedImageCell {
    
    var isShowingLocation: Bool {
        
        return !locationContainer.isHidden
    }

    var locationText: String? {
        
        return locationLabel.text
    }

    var descriptionText: String? {
        
        return descriptionLabel.text
    }
    
    var isShowingImageLoadingIndicator: Bool {
        return feedImageContainer.isShimmering
    }
    
    var renderedImage: Data? {
            return feedImageView.image?.pngData()
        }
}


private extension UIImage {
    static func make(withColor color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}
