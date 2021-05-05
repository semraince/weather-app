//
//  WeatherData.swift
//  weather-app
//
//  Copyright © 2021 semra. All rights reserved.
//

import Foundation

struct WeatherData : Decodable {
    let name: String
    let main: Main
    let weather: [Weather]
    
    var weatherModel: WeatherModel {
        return WeatherModel(countryName: name, temp: main.temp, conditionId: weather.first?.id ?? 0, conditionDescription: weather.first?.description ?? "")
    }
    
}

struct Main: Decodable {
    let temp: Double
}

struct Weather: Decodable {
    let id: Int
    let main: String
    let description: String
}

public struct WeatherModel {
    let countryName: String
    let temp: Double
    let conditionId: Int
    let conditionDescription: String
    
    var conditionImageName: String {
        switch conditionId {
        case 200...299:
           return "imThunderstorm"
        case 300...399:
            return "imDrizzle"
        case 500...599:
            return "imRain"
        case 600...699:
            return "imSnow"
        case 700...799:
            return "imAtmosphere"
        case 800:
            return "imClear";
        case 801...809:
            return "imClouds";
        default:
            return "none";
        }
    }
}
