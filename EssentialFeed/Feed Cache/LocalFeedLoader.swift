//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by ShivaRamReddy on 28/01/21.
//

import Foundation

public final class LocalFeedLoader {
    
    let store: FeedStore
    let items: [FeedItem]
    let currentDate: () -> Date
    
    public typealias SaveResult = Error?
    
    public init(store: FeedStore, items: [FeedItem], currentDate: @escaping () -> Date) {
        
        self.store = store
        self.items = items
        self.currentDate = currentDate
    }
    
    public func save(items: [FeedItem], completion: @escaping (SaveResult) -> ()) {
        
        store.deleteCacheFeed { [weak self] error in
            
            guard let self = self else { return }
            
            if let error = error {
                
                completion(error)
            } else {
                
                self.cache(items:items,currentDate: self.currentDate(), with: completion)
            }
        }
    }
    
    private func cache(items: [FeedItem], currentDate: Date, with completion: @escaping (SaveResult) -> ()) {
        
        store.insert(items: items.toLocal(), currentDate: currentDate) { [weak self] error in
            
            guard let _ = self else { return }
            completion(error)
        }
    }
}

private extension Array where Element == FeedItem {
    
    func toLocal() -> [LocalFeedItem] {
        
        self.map { LocalFeedItem(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.imageURL)}
    }
}
