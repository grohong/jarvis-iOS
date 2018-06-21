//
//  StreamExtensions.swift
//  jarvis-ios
//
//  Created by Seong ho Hong on 2018. 5. 17..
//  Copyright © 2018년 naverlabs. All rights reserved.
//

import Foundation

extension Stream {
    static func boundPair(bufferSize: Int) -> (inputStream: InputStream, outputStream: OutputStream) {
        var inStream: InputStream? = nil
        var outStream: OutputStream? = nil
        Stream.getBoundStreams(withBufferSize: bufferSize, inputStream: &inStream, outputStream: &outStream)
        return (inStream!, outStream!)
    }
    
    static func boundPair(bufferSize: Int, inputStream: InputStream) -> (inputStream: InputStream, outputStream: OutputStream) {
        var inStream: InputStream? = inputStream
        var outStream: OutputStream? = nil
        Stream.getBoundStreams(withBufferSize: bufferSize, inputStream: &inStream, outputStream: &outStream)
        return (inStream!, outStream!)
    }
}
