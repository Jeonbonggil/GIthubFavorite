//
//  SafeArray.swift
//  Sample
//
//  Created by africa on 2020/07/16.
//  Copyright © 2020 africa. All rights reserved.
//

extension Array {
    public subscript(safe index: Int) -> Element? {
        guard index >= 0, index < endIndex else {
            return nil
        }
        return self[index]
    }
    
    public subscript(safe bounds: Range<Int>) -> ArraySlice<Element> {
        if bounds.lowerBound > count { return [] }
        let lower = Swift.max(0, bounds.lowerBound)
        let upper = Swift.max(0, Swift.min(count, bounds.upperBound))
        return self[lower..<upper]
    }
}
