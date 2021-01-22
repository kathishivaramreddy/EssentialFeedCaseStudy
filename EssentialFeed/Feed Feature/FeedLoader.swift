//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by ShivaRamReddy on 21/01/21.
//

public enum LoadFeedResult<Error: Swift.Error> {
    
    case success([FeedItem])
    case failure(Error)
}

extension LoadFeedResult: Equatable where Error: Equatable {}

protocol FeedLoader {
    
    associatedtype Error: Swift.Error
    
    func load(completion: @escaping (LoadFeedResult<Error>) -> Void)
}
