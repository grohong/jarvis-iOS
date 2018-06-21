//
//  LoginWithNaverId.swift
//  jarvis-ios
//
//  Created by Seong ho Hong on 2018. 5. 5..
//  Copyright © 2018년 naverlabs. All rights reserved.
//

import Foundation
import Alamofire

class ClovaAccessTokenManager: NSObject {
    let deviceId = APIKeyManager.deviceId
    
    var clovaAccessToken: String?
    var delegate: ClovaAccessTokenManagerDelegate?
    
    override init() { }
    
    func requestClovaAccessToken(accessToken: String) {
        let header = [
            "Authorization" : "Bearer " + accessToken
        ]
        
        let parameter = [
            "client_id":APIKeyManager.clovaId,
            "device_id":deviceId,
            "model_id":APIKeyManager.naverUrlScheme,
            "response_type":"code",
            "state":"grohong"
        ]
        
        Alamofire.request("https://auth.clova.ai/authorize",
                          parameters: parameter,
                          headers: header).responseJSON { response in
                            switch response.result {
                            case .success:
                                if let result = response.result.value {
                                    let JSON = result as! NSDictionary
                                    let code = JSON["code"]! as! String
                                    self.setClovaToken(authorizationCode: code)
                                }
                            case .failure(let error):
                                print(error)
                            }
        }
    }
    
    private func setClovaToken(authorizationCode: String) {
        let parameter = [
            "client_id":APIKeyManager.clovaId,
            "client_secret":APIKeyManager.clovaSecret,
            "code":authorizationCode,
            "device_id":deviceId,
            "model_id":"jarvis-hackday"
        ]
        
        Alamofire.request("https://auth.clova.ai/token?grant_type=authorization_code",
                          parameters: parameter).responseJSON { response in
                            switch response.result {
                            case .success:
                                if let result = response.result.value {
                                    let JSON = result as! NSDictionary
                                    let accessToken = JSON["access_token"]! as! String
                                    self.clovaAccessToken = accessToken
                                    self.delegate?.clovaConnectionDidFinishRequestAccessToken()
                                }
                            case .failure(let error):
                                print(error)
                            }
        }
    }
    
    // TODO: clova access token valid check
    func isValidClovaAccessToken() -> Bool {
        return true
    }
}

public protocol ClovaAccessTokenManagerDelegate: class {
    func clovaConnectionDidFinishRequestAccessToken() -> Void
}
