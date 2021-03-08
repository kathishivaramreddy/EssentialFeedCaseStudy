//
//  FeedImageCellViewModel.swift
//  EssentialFeediOS
//
//  Created by ShivaRamReddy on 08/03/21.
//

import Foundation
import EssentialFeed

final public class FeedImageCellViewModel<Image> {
    
    private var cellModel: FeedImage
    private var task: FeedImageTaskLoader?
    private var imageLoader: FeedImageLoader
    private var imageTransformer: (Data) -> Image?
    
    init(cellModel: FeedImage, imageLoader: FeedImageLoader, imageTransformer: @escaping (Data) -> Image?) {
        
        self.cellModel = cellModel
        self.imageLoader = imageLoader
        self.imageTransformer = imageTransformer
    }
    
    var isLocationContainerHidden: Bool {
        
        cellModel.location == nil
    }
    
    var description: String? {
        
        cellModel.description
    }
    
    var location: String? {
        
        cellModel.location
    }
    
    var imageURL: URL {
        cellModel.imageURL
    }
    
    var onImageLoad: ((Image) -> Void)?
    var onImageLoadingStateChange: ((Bool) -> Void)?
    var onShouldRetryImageLoadStateChange: ((Bool) -> Void)?
    
    func loadImageData() {
        
        self.onImageLoadingStateChange?(true)
        self.onShouldRetryImageLoadStateChange?(false)
        self.task = self.imageLoader.loadImage(with: self.imageURL) { [weak self] result in
            
            self?.handler(result: result)
            
        }
    }
    
    func handler(result: FeedImageLoader.Result) {
        
        if let image = (try? result.get()).flatMap(imageTransformer) {
            self.onImageLoad?(image)
        } else {
            
            self.onShouldRetryImageLoadStateChange?(true)
        }
        self.onImageLoadingStateChange?(false)
    }
    
    func cancel() {
        
        self.task?.cancel()
        task = nil
    }
}
