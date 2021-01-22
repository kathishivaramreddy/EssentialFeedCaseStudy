//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by ShivaRamReddy on 21/01/21.
//


public struct FeedItem: Equatable {
    
    let id: UUID
    let description: String?
    let location: String?
    let imageURL: URL
}
