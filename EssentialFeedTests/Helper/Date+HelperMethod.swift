//
//  Date+HelperMethod.swift
//  EssentialFeedTests
//
//  Created by ShivaRamReddy on 29/01/21.
//

import Foundation

extension Date {
    
    func minusMaxFeedCacheAge() -> Date {
        return self.adding(days: -feedCacheMaxAgeInDays)
    }
    
    private var feedCacheMaxAgeInDays: Int {
        return 7
    }
    
    private func adding(days: Int) -> Date {
        
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
}

extension Date {
    
    func adding(seconds: TimeInterval) -> Date {
        
        return self + seconds
    }
}
