//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by ShivaRamReddy on 08/03/21.
//

import Foundation
import EssentialFeed
import UIKit

final public class FeedUIComposer {
    
    private init() {}
    
    public static func feedComposedWith(loader: FeedLoader, imageLoader: FeedImageLoader) -> FeedViewController {
        
        let feedPresenter = FeedRefreshPresenter(loader: loader)
        
        let refereshController = FeedRefreshViewController(loadFeed: feedPresenter.loadFeed)
        
        let storyboard = UIStoryboard(name: "Feed", bundle: Bundle(for: FeedViewController.self))
        let feedViewController = storyboard.instantiateInitialViewController() as! FeedViewController
        feedViewController.refereshController = refereshController
        feedPresenter.loadingView = WeakRefVirtualProxy(refereshController)
        feedPresenter.feedView = FeedViewAdapter(controller: feedViewController, imageLoader: imageLoader)
        
        return feedViewController
    }
    
}

private final class WeakRefVirtualProxy<T: AnyObject> {
    
    private weak var object: T?
    
    init(_ object: T) {
        
        self.object = object
    }
}

extension WeakRefVirtualProxy: FeedLoadingView where T: FeedLoadingView {
    
    func display(viewModel: FeedLoadingViewModel) {
        
        self.object?.display(viewModel: viewModel)
    }
}

class FeedViewAdapter: FeedView {
    
    private weak var controller: FeedViewController?
    private var imageLoader: FeedImageLoader
    
    init(controller: FeedViewController, imageLoader: FeedImageLoader) {
        
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    func display(viewModel: FeedViewModel) {
        
        controller?.feedModel = viewModel.feedImages.map({ (feedImage) in
            
            FeedImageCellController(cellViewModel: FeedImageCellViewModel(cellModel: feedImage, imageLoader: imageLoader, imageTransformer: UIImage.init))
        })
    }
}

