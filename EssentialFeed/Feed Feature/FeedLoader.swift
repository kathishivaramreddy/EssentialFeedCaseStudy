//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by ShivaRamReddy on 21/01/21.
//

public enum LoadFeedResult {
    
    case success([FeedImage])
    case failure(Error)
}

public protocol FeedLoader {
        
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
