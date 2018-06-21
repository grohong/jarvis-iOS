//
//  Speaker.swift
//  jarvis-ios
//
//  Created by Seong ho Hong on 2018. 5. 16..
//  Copyright © 2018년 naverlabs. All rights reserved.
//

import Foundation

extension ContextManager {
    func makeContext(volumeState: VolumeState) -> ContextData {
        var volumeStateContext = ContextData()
        volumeStateContext.namespace = "Speaker"
        volumeStateContext.name = "VolumeState"
        
        // set payload
        var payload = [String:Any]()
        payload["volume"] = volumeState.volume
        payload["muted"] = volumeState.muted
        volumeStateContext.payload = payload
        return volumeStateContext
    }
    
    struct VolumeState {
        var muted: Bool
        var volume: Int
    }
}

/*
 {
     "header": {
         "namespace": "Speaker",
         "name": "VolumeState"
     },
     "payload": {
         "volume": {{number}},
         "muted": {{boolean}}
     }
 }
 */
