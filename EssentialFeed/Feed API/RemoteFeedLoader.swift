//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by ShivaRamReddy on 21/01/21.
//

import Foundation



public class RemoteFeedLoader {
    
    private let client: HTTPClient
    private let url: URL
    
    public enum Error: Swift.Error {
        
        case connectivity
        case invalidResponse
    }
    
    public init(url: URL, client: HTTPClient) {
        
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        
        client.get(from: self.url) { result in
            
            switch result {
                
                case let .success(data, response):
                    
                    do {
                        let items = try FeedItemLoader.feedloader(data: data, response: response)
                        completion(.success(items))
                    } catch {
                        
                        completion(.failure(.invalidResponse))
                    }
                case .failure:
                    completion(.failure(.connectivity))
            }
        }
    }
    
    public enum Result: Equatable {
        
        case success([FeedItem])
        case failure(Error)
    }
}
