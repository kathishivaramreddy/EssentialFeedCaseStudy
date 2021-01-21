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
    
    public func load(completion: @escaping (RemoteFeedLoader.Error) -> Void) {
        
        client.get(from: self.url) { error, response in
            
            if response == nil {
                
                completion(.connectivity)
            } else {
                
                completion(.invalidResponse)
            }
        }
    }
}

public protocol HTTPClient {
    
    func get(from url: URL, completion: @escaping (Error?, HTTPURLResponse?) -> Void)
}
