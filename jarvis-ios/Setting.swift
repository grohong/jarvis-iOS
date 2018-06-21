//
//  Setting.swift
//  jarvis-ios
//
//  Created by Seong ho Hong on 2018. 5. 11..
//  Copyright © 2018년 naverlabs. All rights reserved.
//

import Foundation
import AVFoundation

struct Settings {
    struct Audio {
        
        static let TEMP_FILE_NAME = "clova.wav"
        static let RECORDING_SETTING =
            [AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
             AVEncoderBitRateKey: 16,
             AVNumberOfChannelsKey: 1,
             AVSampleRateKey: 16000.0] as [String : Any]
        static let SILENCE_THRESHOLD = -30.0 as Float
    }
}
