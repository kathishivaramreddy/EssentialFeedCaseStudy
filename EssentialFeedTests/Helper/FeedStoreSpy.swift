//
//  FeedStoreSpy.swift
//  EssentialFeedTests
//
//  Created by ShivaRamReddy on 28/01/21.
//

import Foundation
import EssentialFeed

class FeedStoreSpy: FeedStore {

    private var deletionCompletions = [DeletionCompletion]()
    private var insertionCompletion = [InsertionCompletion]()
    private var retrievalCompletion = [RetrievalCompletion]()
    
    enum ReceivedMessage: Equatable {
        
        case deletion
        case insertion(items: [LocalFeedImage], date: Date)
        case retrieve
    }
    
    var receivedMessage = [ReceivedMessage]()
    
    func deleteCacheFeed(completion: @escaping DeletionCompletion) {
        
        deletionCompletions.append(completion)
        receivedMessage.append(.deletion)
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        
        deletionCompletions[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        
        deletionCompletions[index](nil)
    }
    
    func completeInsertion(with error: Error, at index: Int = 0) {
        
        insertionCompletion[index](error)
    }
    
    func insert(items: [LocalFeedImage], currentDate: Date, completion: @escaping InsertionCompletion) {
        
        insertionCompletion.append(completion)
        receivedMessage.append(.insertion(items: items, date: currentDate))
    }
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        
        insertionCompletion[index](nil)
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        
        retrievalCompletion.append(completion)
        receivedMessage.append(.retrieve)
    }
    
    func completeRetrieval(with error: Error, at index: Int = 0) {
        
        retrievalCompletion[index](.failure(error))
    }
        
    func completeRetrievalWithEmptyCache(at index: Int = 0) {
        
        retrievalCompletion[index](.empty)
    }
    
    func completeRetrievalWith(localFeed: [LocalFeedImage], timeStamp: Date, at index: Int = 0) {
        
        retrievalCompletion[index](.found(feedImage: localFeed, timeStamp: timeStamp))
    }
}
