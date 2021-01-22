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
    
    public typealias Result = LoadFeedResult<Error>
    
    public init(url: URL, client: HTTPClient) {
        
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        
        client.get(from: self.url) { [weak self] result in
            
            guard self != nil else { return }
            
            switch result {
                
                case let .success(data, response):
                    
                    completion(FeedItemLoader.map(data, response))
                case .failure:
                    
                    completion(.failure(Error.connectivity))
            }
        }
    }
}
