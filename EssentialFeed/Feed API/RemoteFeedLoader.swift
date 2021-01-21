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
    
    public init(url: URL, client: HTTPClient) {
        
        self.url = url
        self.client = client
    }
    
    public func load() {
        
        client.get(from: self.url)
    }
}

public protocol HTTPClient {
    
    func get(from url: URL)
}
