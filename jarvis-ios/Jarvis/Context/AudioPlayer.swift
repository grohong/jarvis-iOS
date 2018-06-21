//
//  AudioPlayer.swift
//  jarvis-ios
//
//  Created by Seong ho Hong on 2018. 5. 16..
//  Copyright © 2018년 naverlabs. All rights reserved.
//

import Foundation

extension ContextManager {
    func makeContext(playbackState: PlaybackState) -> ContextData {
        var audioPlayerContext = ContextData()
        audioPlayerContext.namespace = "AudioPlayer"
        audioPlayerContext.name = "PlaybackState"
        
        // set payload
        var payload = [String:Any]()
        payload["playerActivity"] = playbackState.playerActivity.rawValue
        payload["repeatMode"] = playbackState.repeatMode.rawValue
        payload["offsetInMilliseconds"] = playbackState.offsetInMilliseconds
        payload["totalInMilliseconds"] = playbackState.totalInMilliseconds
        
        if playbackState.stream != nil {
            // set initiator
            var stream = [String:Any]()
            stream["beginAtInMilliseconds"] = playbackState.stream?.beginAtInMilliseconds
            stream["customData"] = playbackState.stream?.customData
            stream["durationInMilliseconds"] = playbackState.stream?.durationInMilliseconds
            stream["token"] = playbackState.stream?.token
            stream["url"] = playbackState.stream?.url
            stream["urlPlayable"] = playbackState.stream?.urlPlayable
            if playbackState.stream?.progressReport != nil {
                //set progressReport
                var progressReport = [String:Any]()
                progressReport["progressReportDelayInMilliseconds"] = playbackState.stream?.progressReport?.progressReportDelayInMilliseconds
                progressReport["progressReportIntervalInMilliseconds"] = playbackState.stream?.progressReport?.progressReportIntervalInMilliseconds
                progressReport["progressReportPositionInMilliseconds"] = playbackState.stream?.progressReport?.progressReportPositionInMilliseconds
                stream["progressReport"] = progressReport
            }
            payload["stream"] = stream
        }
        
        audioPlayerContext.payload = payload
        return audioPlayerContext
    }
    
    struct PlaybackState {
        var offsetInMilliseconds: Int?
        var playerActivity: PlayerActivity = PlayerActivity.IDLE
        var repeatMode: RepeatMode = RepeatMode.NONE
        var stream: AudioStream?
        var totalInMilliseconds: Int?
    }
    
    struct AudioStream {
        var beginAtInMilliseconds: Int
        var customData: String?
        var durationInMilliseconds: Int?
        var progressReport: ProgressReport?
        var token: String
        var url: String
        var urlPlayable: Bool
    }
    
    struct ProgressReport {
        var progressReportDelayInMilliseconds: Int?
        var progressReportIntervalInMilliseconds: Int?
        var progressReportPositionInMilliseconds: Int?
    }
    
    enum PlayerActivity: String {
        case IDLE = "IDLE"
        case PLAYING = "PLAYING"
        case PAUSED = "PAUSED"
        case STOPPED = "STOPPED"
        case FINISHED = "FINISHED"
    }
    
    enum RepeatMode: String {
        case NONE = "NONE"
        case REPEAT_ONE = "REPEAT_ONE"
    }
}

/*
 {
     "header": {
         "namespace": "AudioPlayer",
         "name": "PlaybackState"
     },
     "payload": {
         "offsetInMilliseconds": {{number}},
         "playerActivity": {{string}},
         "repeatMode": {{string}},
         "stream": {{AudioStreamInfoObject}},
         "totalInMilliseconds": {{number}}
     }
 }
 */
