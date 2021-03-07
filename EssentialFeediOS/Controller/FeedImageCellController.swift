//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by ShivaRamReddy on 07/03/21.
//

import Foundation
import UIKit

import EssentialFeed

final public class FeedImageCellController {
    
    private var task: FeedImageTaskLoader?
    private var imageLoader: FeedImageLoader
    private var cellModel: FeedImage
    
    init(imageLoader: FeedImageLoader, cellModel: FeedImage) {
        
        self.imageLoader = imageLoader
        self.cellModel = cellModel
    }
    
    public func view() -> UITableViewCell {
                
        let cell = FeedImageCell()
        cell.locationContainer.isHidden = (cellModel.location == nil)
        cell.descriptionLabel.text = cellModel.description
        cell.locationLabel.text = cellModel.location
        
        cell.feedImageContainer.startShimmering()
        cell.feedRetryButton.isHidden = true
        cell.feedImageView.image = nil
        
        let loadImage = { [weak self, weak cell] in
            
            guard let self = self else { return }
            
            self.task = self.imageLoader.loadImage(with: self.cellModel.imageURL) { [weak cell] result in
                
                if let data = try? result.get(), let image = UIImage(data: data) {
                    
                    cell?.feedImageView.image = image
                } else {
                    
                    cell?.feedRetryButton.isHidden = false
                }
                cell?.feedImageContainer.stopShimmering()
            }
        }
        cell.onRetry = loadImage
        
        loadImage()
        
        return cell
    }
    
    func preLoad() {
        
        self.task = self.imageLoader.loadImage(with: cellModel.imageURL, completion: { _ in
        })
    }
    
    deinit {
        
        self.task?.cancel()
    }
}
