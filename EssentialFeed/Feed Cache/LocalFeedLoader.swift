//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by ShivaRamReddy on 28/01/21.
//

import Foundation

public final class LocalFeedLoader {
    
    let store: FeedStore
    let items: [FeedImage]
    let currentDate: () -> Date
    
    public typealias SaveResult = Error?
    public typealias LoadResult = LoadFeedResult
    
    public init(store: FeedStore, items: [FeedImage], currentDate: @escaping () -> Date) {
        
        self.store = store
        self.items = items
        self.currentDate = currentDate
    }
    
    public func save(items: [FeedImage], completion: @escaping (SaveResult) -> ()) {
        
        store.deleteCacheFeed { [weak self] error in
            
            guard let self = self else { return }
            
            if let error = error {
                
                completion(error)
            } else {
                
                self.cache(items:items,currentDate: self.currentDate(), with: completion)
            }
        }
    }
    
    private func cache(items: [FeedImage], currentDate: Date, with completion: @escaping (SaveResult) -> ()) {
        
        store.insert(items: items.toLocal(), currentDate: currentDate) { [weak self] error in
            
            guard let _ = self else { return }
            completion(error)
        }
    }
    
    public func load(with completion: @escaping (LoadResult) -> ()) {

        store.retrieve { result in
            
            switch result {
                
                case .empty:
                    completion(.success([]))
                case let .failure(error):
                completion(.failure(error))
                case let .found(feedImage: localFeedImage, timeStamp: _):
                    completion(.success(localFeedImage.toModels()))
            }
        }
    }
}

private extension Array where Element == FeedImage {
    
    func toLocal() -> [LocalFeedImage] {
        
        self.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.imageURL)}
    }
}

private extension Array where Element == LocalFeedImage {
    
    func toModels() -> [FeedImage] {
        
        self.map { FeedImage(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.imageURL)}
    }
}
