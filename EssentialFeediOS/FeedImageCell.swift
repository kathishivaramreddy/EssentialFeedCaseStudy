//
//  FeedImageCell.swift
//  EssentialFeed
//
//  Created by ShivaRamReddy on 07/03/21.
//

import Foundation
import UIKit

public class FeedImageCell: UITableViewCell {
    
    public let locationContainer = UIView()
    public let locationLabel = UILabel()
    public let descriptionLabel = UILabel()
    public let feedImageContainer = UIView()
    public let feedImageView = UIImageView()
    private(set) public lazy var feedRetryButton: UIButton = {
        
        let button = UIButton()
        button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    var onRetry: (() -> Void)?
    
    @objc func retryButtonTapped() {
        
        onRetry?()
    }
}
