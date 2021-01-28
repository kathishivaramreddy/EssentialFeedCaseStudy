//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by ShivaRamReddy on 28/01/21.
//

import Foundation

struct RemoteFeedItem: Decodable {
    
    let id: UUID
    let description: String?
    let location: String?
    let image: URL
}
