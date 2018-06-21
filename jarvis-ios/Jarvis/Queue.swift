//
//  Queue.swift
//  jarvis-ios
//
//  Created by Seong ho Hong on 2018. 5. 14..
//  Copyright © 2018년 naverlabs. All rights reserved.
//

import Foundation

public struct Queue<T> {
    fileprivate var list = LinkedList<T>()
    
    public mutating func enqueue(_ element: T) {
        list.append(value: element)
    }
    
    public mutating func dequeue() -> T? {
        guard !list.isEmpty, let element = list.first else { return nil }
        
        list.remove(node: element)
        
        return element.value
    }
    
    public func peek() -> T? {
        return list.first?.value
    }
    
    public var isEmpty: Bool {
        return list.isEmpty
    }
}
