//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by ShivaRamReddy on 21/01/21.
//

import Foundation

public class RemoteFeedLoader: FeedLoader {
    
    private let client: HTTPClient
    private let url: URL
    
    public enum Error: Swift.Error {
        
        case connectivity
        case invalidResponse
    }
    
    public typealias Result = LoadFeedResult
    
    public init(url: URL, client: HTTPClient) {
        
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        
        client.get(from: self.url) { [weak self] result in
            
            guard self != nil else { return }
            
            switch result {
                
                case let .success(data, response):
                    
                    completion(RemoteFeedLoader.map(data: data, response: response))
                case .failure:
                    
                    completion(.failure(Error.connectivity))
            }
        }
    }
    
    private static func map(data: Data, response: HTTPURLResponse) -> Result {
        
        do {
            
            let items = try FeedItemMapper.map(data, response)
             return .success(items.toModels())
        } catch {
            
            return .failure(error)
        }
    }
}

private extension Array where Element == RemoteFeedItem {
    
    func toModels() -> [FeedItem] {
        
        return self.map { FeedItem(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.image) }
    }
}
