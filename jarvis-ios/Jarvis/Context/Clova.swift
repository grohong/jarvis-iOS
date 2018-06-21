//
//  Clova.swift
//  jarvis-ios
//
//  Created by Seong ho Hong on 2018. 5. 16..
//  Copyright © 2018년 naverlabs. All rights reserved.
//

import Foundation

extension ContextManager {
    func makeContext(location: Location) -> ContextData {
        var locationContext = ContextData()
        locationContext.namespace = "Clova"
        locationContext.name = "Location"
        
        // set payload
        var payload = [String:Any]()
        payload["latitude"] = location.latitude
        payload["longitude"] = location.longitude
        payload["refreshedAt"] = location.refreshedAt
        locationContext.payload = payload
        return locationContext
    }
    
    struct Location {
        var latitude: String
        var longitude: String
        var refreshedAt: String
    }
    
    func makeContext(savedPlace: SavedPlace) -> ContextData {
        var savedPlaceContext = ContextData()
        savedPlaceContext.namespace = "Clova"
        savedPlaceContext.name = "SavedPlace"
        
        // set payload
        var payload = [String:Any]()
        var places = [[String:Any]]()
        for place in savedPlace.place {
            var placeJson = [String:Any]()
            placeJson["latitude"] = place.latitude
            placeJson["longitude"] = place.longitude
            placeJson["name"] = place.name
            placeJson["refreshedAt"] = place.refreshedAt
            places.append(placeJson)
        }
        payload["places"] = places
        savedPlaceContext.payload = payload
        return savedPlaceContext
    }
    
    struct SavedPlace {
        var place: [Place]
    }
    
    struct Place {
        var latitude: String
        var longitude: String
        var name: String
        var refreshedAt: String
    }
}
/*
 {
     "header": {
         "namespace": "Clova",
         "name": "Location"
     },
     "payload": {
         "latitude": {{string}},
         "longitude": {{string}},
         "refreshedAt": {{string}}
     }
 }
 */

/*
 {
     "header": {
         "namespace": "Clova",
         "name": "SavedPlace"
     },
     "payload": {
         "places": [
             {
                 "latitude": {{string}},
                 "longitude": {{string}},
                 "refreshedAt": {{string}},
                 "name": {{string}}
             }
         ]
     }
 }
 */
