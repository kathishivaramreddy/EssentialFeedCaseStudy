//
//  CodableFeedStore.swift
//  EssentialFeed
//
//  Created by ShivaRamReddy on 31/01/21.
//

import Foundation

public class CodableFeedStore: FeedStore {
    
    private struct Cache: Codable {
        
        let items: [CodableFeedImage]
        let timeStamp: Date
        
        var local: [LocalFeedImage] {
            
            return items.map { $0.local }
        }
    }
    
    private struct CodableFeedImage: Codable {
        
        private let id: UUID
        private let description: String?
        private let location: String?
        private let imageURL: URL
        
        public init(_ image: LocalFeedImage) {
            self.id = image.id
            self.description = image.description
            self.location = image.location
            self.imageURL = image.imageURL
        }
        
        var local: LocalFeedImage {
            
            return LocalFeedImage(id: id, description: description, location: location, imageURL: imageURL)
        }
    }
    
    private let storeUrl: URL
    
    public init(storeUrl: URL) {
        
        self.storeUrl = storeUrl
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        
        guard let data = try? Data(contentsOf: storeUrl) else {
            
            return completion(.empty)
        }
        
        let decoder = JSONDecoder()
        
        do {
            
            let decoded = try decoder.decode(Cache.self, from: data)
            
            completion(.found(feedImage: decoded.local, timeStamp: decoded.timeStamp))
        }catch {
            
            completion(.failure(error))
        }
        
    }
    
    public func insert(items: [LocalFeedImage], currentDate: Date, completion: @escaping InsertionCompletion) {
        
        do {
            
            let encoder = JSONEncoder()
            let cache = Cache(items: items.map { CodableFeedImage($0)}, timeStamp: currentDate)
            let encoded = try! encoder.encode(cache)
            try encoded.write(to: storeUrl)
            completion(nil)
        } catch {
            completion(error)
        }
    }
    
    public func deleteCacheFeed(completion: @escaping DeletionCompletion) {
        
        guard FileManager.default.fileExists(atPath: storeUrl.path) else {
            return completion(nil)
        }
        
        do {
            
            try FileManager.default.removeItem(at: storeUrl)
            completion(nil)
        } catch {
            completion(error)
        }
    }
}
