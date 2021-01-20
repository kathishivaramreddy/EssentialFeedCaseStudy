//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by ShivaRamReddy on 21/01/21.
//

enum LoadFeedResult {
    
    case success([FeedItem])
    case error(Error)
}

protocol FeedLoader {
    
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
