//
//  CacheLocationManager.swift
//  weather-app
//
//  Created by semra on 9.05.2021.
//  Copyright © 2021 semra. All rights reserved.
//

import Foundation

public struct CacheLocationManager {
    private let vault = UserDefaults.standard;
    
    enum Key : String {
        case lat;
        case lng;
    }
    
    public func cacheCoordinates(lat: Double, lng: Double){
        vault.set(lat, forKey: Key.lat.rawValue);
        vault.set(lng, forKey: Key.lng.rawValue);
    }
    
    public func getCoordinates() -> (Double?, Double?) {
        let lat = vault.value(forKey: Key.lat.rawValue) as? Double
        let lng = vault.value(forKey: Key.lng.rawValue) as? Double
        
        return (lat,lng);
    }
}
