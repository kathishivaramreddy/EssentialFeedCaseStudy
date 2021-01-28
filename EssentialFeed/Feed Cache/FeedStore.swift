//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by ShivaRamReddy on 28/01/21.
//

import Foundation

public enum RetrievedFeedCacheResult {
    
    case empty
    case found(feedImage: [LocalFeedImage], timeStamp: Date)
    case failure(Error)
}

public protocol FeedStore {
    
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    typealias RetrievalCompletion = (RetrievedFeedCacheResult) -> Void
    
    func deleteCacheFeed(completion: @escaping DeletionCompletion)
    func insert(items: [LocalFeedImage], currentDate: Date, completion: @escaping InsertionCompletion)
    func retrieve(completion: @escaping RetrievalCompletion)
}
