//
//  ContextManager.swift
//  jarvis-ios
//
//  Created by Seong ho Hong on 2018. 5. 15..
//  Copyright © 2018년 naverlabs. All rights reserved.
//

import Foundation
import MapKit

class ContextManager {
    var contextArray = [ContextData]()
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    var userLatitude: String = "37.3594915"
    var userLongitude: String = "127.1032242"
    
    func defaultContext() -> [ContextData] {
        // now date info
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSXXXXX"
        var timeAt = formatter.string(from: now)
        
        // location info
        locationManager.requestWhenInUseAuthorization()
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
            currentLocation = locationManager.location
            userLatitude = currentLocation.coordinate.latitude.description
            userLongitude = currentLocation.coordinate.longitude.description
        } else {
            timeAt = "2017-04-06T13:34:15.074361+08:28"
        }
        
        // for display context
        let bounds = UIScreen.main.bounds
        let width = Int(bounds.size.width)
        let height = Int(bounds.size.height)
        var display = Display()
        display.contentLayer = ContentLayer(width: width, height: height)
        display.dpi = 320
        display.orientation = Orientation.portrait
        
        let location = Location(latitude: userLatitude, longitude: userLongitude, refreshedAt: timeAt)
        // initializing context object
        contextArray = [ContextData]()
        contextArray.append(makeContext(alertState: AlertsState()))
        contextArray.append(makeContext(playbackState: PlaybackState()))
        contextArray.append(makeContext(location: location))
        contextArray.append(makeContext(savedPlace: SavedPlace(place: [])))
        contextArray.append(makeContext(deviceState: DeviceState()))
        contextArray.append(makeContext(display: display))
        contextArray.append(makeContext(volumeState: VolumeState(muted: false, volume: 10)))
        contextArray.append(makeContext(speechState: SpeechState(token: "dc706e02-fe16-4337-9a6c-51f670b5adb2",
                                                                 playerActivity: PlayerActivity.FINISHED)))
        
        return contextArray
    }
    
    private func jsonToString(json: [String:Any]) -> String {
        var string = ""
        do {
            let data =  try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted) // first of all convert json to the data
            if let convertedString = String(data: data, encoding: String.Encoding.utf8) {
                string = convertedString
            } // the data will be converted to the string
        } catch let myJSONError {
            print(myJSONError)
        }
        return string
    }
    
    func getContextString() -> String {
        let CONTEXT_ARRAY_DATA_TEMPLATE = "\"context\": [$contextArray]"
        var contextArrayMessage = CONTEXT_ARRAY_DATA_TEMPLATE
        var contextArrayString = ""
        for i in 0..<contextArray.count {
            let CONTEXT_DATA_TEMPLATE = "{\"header\": {\"namespace\": \"$namespace\",\"name\": \"$name\"},\"payload\": $payload}"
            var contextMessage = CONTEXT_DATA_TEMPLATE
            contextMessage = contextMessage.replacingOccurrences(of: "$namespace", with: contextArray[i].namespace)
            contextMessage = contextMessage.replacingOccurrences(of: "$name", with: contextArray[i].name)
            contextMessage = contextMessage.replacingOccurrences(of: "$payload", with: jsonToString(json: contextArray[i].payload))
            contextArrayString = contextArrayString + contextMessage
            if i != (contextArray.count - 1) {
                contextArrayString = contextArrayString + ", "
            }
        }
        contextArrayMessage = contextArrayMessage.replacingOccurrences(of: "$contextArray", with: contextArrayString)
        return contextArrayMessage
    }
    
    struct ContextData {
        var namespace = String()
        var name = String()
        var payload = [String:Any]()
    }
}

/*
Alerts.AlertsState
AudioPlayer.PlaybackState
Clova.Location
Clova.SavedPlace
Device.DeviceState
Device.Display
Speaker.VolumeState
SpeechSynthesizer.SpeechState
 */
