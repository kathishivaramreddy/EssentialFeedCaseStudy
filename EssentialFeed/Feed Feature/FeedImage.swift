//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by ShivaRamReddy on 21/01/21.
//


public struct FeedImage: Equatable {
    
    public let id: UUID
    public let description: String?
    public let location: String?
    public let imageURL: URL
    
    public init(id : UUID
                , description: String?
                , location: String?
                , imageURL: URL) {
        
        self.id = id
        self.description = description
        self.location = location
        self.imageURL = imageURL
    }
}

extension FeedImage: Decodable {
    
    private enum CodingKeys: String, CodingKey {
        
        case id
        case description
        case location
        case imageURL = "image"
    }
}
