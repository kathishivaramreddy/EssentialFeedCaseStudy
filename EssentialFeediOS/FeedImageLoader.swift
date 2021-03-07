//
//  FeedImageLoader.swift
//  EssentialFeediOS
//
//  Created by ShivaRamReddy on 07/03/21.
//

import Foundation

public protocol FeedImageLoader {
    
    typealias Result = Swift.Result<Data, Error>
    
    func loadImage(with url: URL, completion: @escaping (Result) -> Void) -> FeedImageTaskLoader
}
