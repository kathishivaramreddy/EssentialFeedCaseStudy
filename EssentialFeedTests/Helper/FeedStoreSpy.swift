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
    
    func retrieve() {
        
        receivedMessage.append(.retrieve)
    }
}
