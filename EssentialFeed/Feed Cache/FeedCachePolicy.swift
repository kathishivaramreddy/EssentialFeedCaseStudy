//
//  FeedCachePolicy.swift
//  EssentialFeed
//
//  Created by ShivaRamReddy on 30/01/21.
//

import Foundation

final class FeedCachePolicy {
    
    private let currentDate: () -> Date
    private let calendar = Calendar(identifier: .gregorian)
    
    public init(currentDate: @escaping () -> Date) {
        
        self.currentDate = currentDate
    }
    
    private var maxCacheAgeInDays: Int {
        return 7
    }
    
    func validate(_ timestamp: Date) -> Bool {
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else {
            return false
        }
        return self.currentDate() < maxCacheAge
    }
}
