//
//  APIKeyManager.swift
//  jarvis-ios
//
//  Created by Seong ho Hong on 2018. 5. 9..
//  Copyright © 2018년 naverlabs. All rights reserved.
//

import Foundation

struct APIKeyManager {
    
    static let naverClientID: String = {
        return getAPIKey(keyName: "NaverClientID")
    }()
    
    static let naverClientSecret: String = {
        return getAPIKey(keyName: "NaverClientSecret")
    }()
    
    static let naverUrlScheme: String = {
        return getAPIKey(keyName: "NaverUrlScheme")
    }()
    
    static let clovaId: String = {
        return getAPIKey(keyName: "ClovaId")
    }()
    
    static let clovaSecret: String = {
        return getAPIKey(keyName: "ClovaSecret")
    }()
    
    static let deviceId: String = {
        if let existDiviceId = UserDefaults.standard.string(forKey: "DeviceId") {
            return existDiviceId
        } else {
            let newDeviceId = UUID().uuidString
            UserDefaults.standard.setValue(newDeviceId, forKey: "DeviceId")
            UserDefaults.standard.synchronize()
            
            return newDeviceId
        }
    }()
    
    static func getAPIKey(keyName: String) -> String {
        if let path = Bundle.main.path(forResource: "ClovaAPIKey", ofType: "plist"),
            let dict = NSDictionary(contentsOfFile: path) as? [String: String] {
            if let clientSecret = dict[keyName] {
                return clientSecret
            }
        }
        return ""
    }
}
