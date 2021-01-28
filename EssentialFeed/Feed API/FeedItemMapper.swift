//
//  FeedItemLoader.swift
//  EssentialFeed
//
//  Created by ShivaRamReddy on 22/01/21.
//

import Foundation

struct FeedItemMapper {
    
    private static var OK_200 = 200
    
    static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        
        guard response.statusCode == OK_200
              , let root = try? JSONDecoder().decode(Root.self, from: data)
        else {
            
            throw RemoteFeedLoader.Error.invalidResponse
        }
        
        return root.items
    }
}

struct Root: Decodable {
    
    let items: [RemoteFeedItem]
}

struct RemoteFeedItem: Decodable {
    
    let id: UUID
    let description: String?
    let location: String?
    let image: URL
}
