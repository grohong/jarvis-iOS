//
//  Alerts.swift
//  jarvis-ios
//
//  Created by Seong ho Hong on 2018. 5. 15..
//  Copyright © 2018년 naverlabs. All rights reserved.
//

import Foundation

extension ContextManager {
    func makeContext(alertState: AlertsState) -> ContextData {
        var alertsContext = ContextData()
        alertsContext.namespace = "Alerts"
        alertsContext.name = "AlertsState"
        
        // set payload
        var payload = [String:Any]()
        var allAlerts = [[String:Any]]()
        var activeAlerts = [[String:Any]]()
        
        for alert in alertState.allAlerts {
            var alertJson = [String:Any]()
            alertJson["token"] = alert.token
            alertJson["type"] = alert.type.rawValue
            alertJson["scheduledTime"] = alert.scheduledTime
            allAlerts.append(alertJson)
        }
        
        for alert in alertState.activeAlerts {
            var alertJson = [String:Any]()
            alertJson["token"] = alert.token
            alertJson["type"] = alert.type.rawValue
            alertJson["scheduledTime"] = alert.scheduledTime
            activeAlerts.append(alertJson)
        }
        
        payload["allAlerts"] = allAlerts
        payload["activeAlerts"] = activeAlerts
        alertsContext.payload = payload
        
        return alertsContext
    }
    
    struct AlertsState {
        var allAlerts = [Alert]()
        var activeAlerts = [Alert]()
    }

    struct Alert {
        var token: String
        var type: AlertType
        var scheduledTime: String
    }
    
    enum AlertType: String {
        case ACTIONTIMER = "ACTIONTIMER"
        case ALARM = "ALARM"
        case REMINDER = "REMINDER"
        case TIMER = "TIMER"
    }
    
    /*
     {
        "header": {
        "namespace": "Alerts",
        "name": "AlertsState"
        },
        "payload": {
            "allAlerts": [
                {
                     "token": {{string}},
                     "type": {{string}},
                     "scheduledTime": {{string}}
                }
            ],
         "activeAlerts": [
                 {
                     "token": {{string}},
                     "type": {{string}},
                     "scheduledTime": {{string}}
                }
            ]
        }
     }
     */
}
