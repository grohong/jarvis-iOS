//
//  SpeechSynthesizer.swift
//  jarvis-ios
//
//  Created by Seong ho Hong on 2018. 5. 16..
//  Copyright © 2018년 naverlabs. All rights reserved.
//

import Foundation

extension ContextManager {
    func makeContext(speechState: SpeechState) -> ContextData {
        var speechStateContext = ContextData()
        speechStateContext.namespace = "SpeechSynthesizer"
        speechStateContext.name = "SpeechState"
        
        // set payload
        var payload = [String:Any]()
        payload["token"] = speechState.token
        payload["playerActivity"] = speechState.playerActivity.rawValue
        speechStateContext.payload = payload
        return speechStateContext
    }

    struct SpeechState {
        var token: String
        var playerActivity: PlayerActivity
    }
}

/*
 {
     "header": {
         "namespace": "SpeechSynthesizer",
         "name": "SpeechState"
     },
     "payload": {
         "token": {{string}},
         "playerActivity": {{string}}
     }
 }
 */
