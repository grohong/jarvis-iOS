//
//  StringExtensions.swift
//  jarvis-ios
//
//  Created by Seong ho Hong on 2018. 5. 11..
//  Copyright © 2018년 naverlabs. All rights reserved.
//

import Foundation

extension String {
    public func stringByIndex(from: String.Index? = nil, to: String.Index? = nil) -> String {
        if let fromIndex = from, let toIndex = to {
            return String(self[fromIndex..<toIndex])
        } else if let fromIndex = from {
            return String(self[fromIndex...])
        } else if let toIndex = to {
            return String(self[..<toIndex])
        }
        return self
    }
}
