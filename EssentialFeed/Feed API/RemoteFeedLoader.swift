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
    
    public enum Result: Equatable {
        
        case success([FeedItem])
        case failure(Error)
    }
    
    public init(url: URL, client: HTTPClient) {
        
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        
        client.get(from: self.url) { [weak self] result in
            
            guard let strongSelf = self else { return }
            switch result {
                
                case let .success(data, response):
                    
                    completion(strongSelf.map(data, response))
                case .failure:
                    
                    completion(.failure(.connectivity))
            }
        }
    }
    
    private func map(_ data: Data, _ response: HTTPURLResponse) -> Result {
        
        do {
            
            let items = try FeedItemLoader.feedloader(data: data, response: response)
            return .success(items)
        } catch {
            
            return .failure(.invalidResponse)
        }
    }
}
