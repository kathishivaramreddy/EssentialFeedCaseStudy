//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by ShivaRamReddy on 28/01/21.
//

import Foundation

public final class LocalFeedLoader {
    
    private let store: FeedStore
    private let currentDate: () -> Date
    
    private let calendar = Calendar(identifier: .gregorian)
    
    public typealias SaveResult = Error?
    public typealias LoadResult = LoadFeedResult
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        
        self.store = store
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

        store.retrieve { [weak self] result in
            
            guard let self = self else { return }
            switch result {
                
                case let .failure(error):
                    completion(.failure(error))
                case let .found(feedImage: localFeedImage, timeStamp: timeStamp) where self.validate(timeStamp):
                    completion(.success(localFeedImage.toModels()))
                case .found:
                    completion(.success([]))
                case .empty:
                    completion(.success([]))
            }
        }
    }
    
    public func validateCache() {
        
        store.retrieve { [unowned self] result in
                        
            switch result {
                
                case .failure:
                    self.store.deleteCacheFeed { _ in }
                case let .found(feedImage: _, timeStamp: timeStamp) where !self.validate(timeStamp):
                    self.store.deleteCacheFeed { _ in }
                default:
                    break
            }
        }
    }
    
    private var maxCacheAgeInDays: Int {
        return 7
    }
    
    private func validate(_ timestamp: Date) -> Bool {
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else {
            return false
        }
        return currentDate() < maxCacheAge
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
