//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by ShivaRamReddy on 21/01/21.
//

public typealias LoadFeedResult = Result<[FeedImage], Error>

public protocol FeedLoader {
        
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
