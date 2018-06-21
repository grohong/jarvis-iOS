//
//  PCMBuffer.swift
//  Jarvis-hackday
//
//  Created by soojin on 17/05/2018.
//  Copyright © 2018 NSoojin. All rights reserved.
//

import Foundation

let BufferSize = 6400

public class PCMBuffer {
    
    var buffer: Data
    let lock = NSCondition()
    var isCancelled = false
    
    init() {
        self.buffer = Data()
    }
    
    func enqueue(_ data: Data) {
        if !data.isEmpty {
            lock.lock()
            buffer.append(data)
            lock.signal()
            lock.unlock()
        }
    }
    
    func dequeue() -> Data {
        lock.lock()
        
        while buffer.count < BufferSize {
            if isCancelled {
                lock.unlock()
                return Data()
            }
            
            lock.wait()
        }
        
        let result = buffer.subdata(in: 0..<BufferSize)
        
        let remainder = buffer.subdata(in: BufferSize..<buffer.count)
        
        buffer = remainder
        lock.unlock()
        
        return result
    }
    
    func ready() {
        lock.lock()
        buffer = Data(count: 0)
        isCancelled = false
        lock.unlock()
    }
    
    func clear() {
        lock.lock()
        buffer = Data(count: 0)
        isCancelled = true
        lock.signal()
        lock.unlock()
    }
}
