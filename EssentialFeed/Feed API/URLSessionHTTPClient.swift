//
//  URLSessionHTTPClient.swift
//  EssentialFeed
//
//  Created by ShivaRamReddy on 23/01/21.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {
    
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        
        self.session = session
    }
    
    private struct UnexpectedValueRepresentationError: Error {}
    
    public func get(from url: URL, completion completionHandler: @escaping (HTTPClientResponse) -> Void) {
        
        self.session.dataTask(with: url) { (data, response, error) in
            
            if let error = error {
                
                completionHandler(.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse {
                
                completionHandler(.success(data, response))
            } else {
                
                completionHandler(.failure(UnexpectedValueRepresentationError()))
            }
        }.resume()
    }
}
