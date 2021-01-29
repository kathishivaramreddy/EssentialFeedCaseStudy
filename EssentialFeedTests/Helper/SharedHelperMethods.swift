//
//  SharedHelperMethods.swift
//  EssentialFeedTests
//
//  Created by ShivaRamReddy on 29/01/21.
//

import Foundation
import EssentialFeed

func uniqueItem() -> FeedImage {
    return FeedImage(id: UUID(), description: "any", location: "any", imageURL: anyURL())
}

func uniqueItems() -> (models: [FeedImage], localItems: [LocalFeedImage]) {
    
    let items = [uniqueItem(), uniqueItem()]
    let localItems = items.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.imageURL) }
    
    return (items, localItems)
}

func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
}

func anyNSError() -> NSError {
    
    NSError(domain: "any error", code: 0, userInfo: nil)
}
