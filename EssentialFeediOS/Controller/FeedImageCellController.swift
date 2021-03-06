//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by ShivaRamReddy on 07/03/21.
//

import Foundation
import UIKit

final public class FeedImageCellController {
    
    private var cellViewModel: FeedImageCellViewModel<UIImage>
    init(cellViewModel: FeedImageCellViewModel<UIImage>) {
        
        self.cellViewModel = cellViewModel
    }
    
    public func view(in tableView: UITableView) -> UITableViewCell {
                
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedImageCell") as! FeedImageCell
        cell.locationContainer.isHidden = cellViewModel.isLocationContainerHidden
        cell.descriptionLabel.text = cellViewModel.description
        cell.locationLabel.text = cellViewModel.location
        cell.onRetry = self.cellViewModel.loadImageData
        
        cellViewModel.onImageLoad = { [weak cell] image in
            
            cell?.feedImageView.alpha = 0
            cell?.feedImageView.image = image
            
            UIView.animate(withDuration: 0.25) {
                
                cell?.feedImageView.alpha = 1
            }
        }
        
        cellViewModel.onImageLoadingStateChange = { [weak cell] isLoading in
            if isLoading {
                cell?.feedImageContainer.startShimmering()
            } else {
                cell?.feedImageContainer.stopShimmering()
            }
        }
        
        cellViewModel.onShouldRetryImageLoadStateChange = { [weak cell] shouldRetry in
            
            cell?.feedRetryButton.isHidden = !shouldRetry
        }
        
        self.cellViewModel.loadImageData()
        
        return cell
    }
    
    func preLoad() {
        
        self.cellViewModel.loadImageData()
    }
    
    func cancel() {

        self.cellViewModel.onImageLoad = nil
        self.cellViewModel.cancel()
    }
}
