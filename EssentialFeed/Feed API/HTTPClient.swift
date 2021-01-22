//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by ShivaRamReddy on 22/01/21.
//

import Foundation

public enum HTTPClientResponse {
    
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    
    func get(from url: URL, completion: @escaping (HTTPClientResponse) -> Void)
}
