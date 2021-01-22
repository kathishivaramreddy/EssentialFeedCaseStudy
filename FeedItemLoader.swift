//
//  FeedItemLoader.swift
//  EssentialFeed
//
//  Created by ShivaRamReddy on 22/01/21.
//

import Foundation

struct FeedItemLoader {
    
    private static var OK_200 = 200
    
    public struct Root: Decodable {
        
        let items: [Item]
        
        var feed: [FeedItem] {
            
            items.map { $0.feedItem }
        }
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

    static func map(_ data: Data, _ response: HTTPURLResponse) -> RemoteFeedLoader.Result {
        
        guard response.statusCode == OK_200
              , let root = try? JSONDecoder().decode(Root.self, from: data)
        else {
            
            return .failure(RemoteFeedLoader.Error.invalidResponse)
        }
        
        return .success(root.feed)
    }
}

