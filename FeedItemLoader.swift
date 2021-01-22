//
//  FeedItemLoader.swift
//  EssentialFeed
//
//  Created by ShivaRamReddy on 22/01/21.
//

import Foundation

struct FeedItemLoader {
    
    private static var OK_200 = 200
    
    static func feedloader(data: Data, response: HTTPURLResponse) throws -> [FeedItem] {
        
        guard response.statusCode == OK_200 else {
            
            throw RemoteFeedLoader.Error.invalidResponse
        }
        
        let root = try JSONDecoder().decode(Root.self, from: data)
        
        return root.items.map { $0.feedItem }
    }
    
    public struct Root: Decodable {
        
        let items: [Item]
    }

    public struct Item: Decodable {
        
        let id: UUID
        let description: String?
        let location: String?
        let image: URL
        
        var feedItem: FeedItem {
            
            return FeedItem(id: id
                            , description: description
                            , location: location
                            , imageURL: image)
        }
    }

}

