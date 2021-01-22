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
                    
                    if response.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data) {
                        
                        completion(.success(root.items))
                    } else {
                        
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


public enum HTTPClientResponse {
    
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    
    func get(from url: URL, completion: @escaping (HTTPClientResponse) -> Void)
}

public struct Root: Decodable {
    
    let items: [FeedItem]
}


