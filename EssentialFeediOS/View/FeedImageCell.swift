//
//  FeedImageCell.swift
//  EssentialFeed
//
//  Created by ShivaRamReddy on 07/03/21.
//

import Foundation
import UIKit

public class FeedImageCell: UITableViewCell {
    
    @IBOutlet public var locationContainer: UIView!
    @IBOutlet public var locationLabel: UILabel!
    @IBOutlet public var descriptionLabel: UILabel!
    @IBOutlet public var feedImageContainer: UIView!
    @IBOutlet public var feedImageView: UIImageView!
    @IBOutlet public var feedRetryButton: UIButton!
    
    var onRetry: (() -> Void)?
    
    @IBAction func retryButtonTapped() {
        
        onRetry?()
    }
}
