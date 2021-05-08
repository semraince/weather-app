//
//  ErrorMessages.swift
//  weather-app
//s
//  Copyright © 2021 semra. All rights reserved.
//

import Foundation

enum WeatherError: Error, LocalizedError {
    case unknown;
    case invalidCity;
    case customDescription(String)
    var errorDescription: String? {
        switch self {
        case .invalidCity :
            return "Invalid City"
        case .unknown:
            return "There is an unknown error";
        case .customDescription(let errorMessage):
            return errorMessage;
        }
        
        
    }
    
}

enum ErrorMessages {
    static let unableToHandleRequest = "We are currently unable to process your request. Please try again later";
    static let emptySearchText = "City cannot be empty!";
    static let locationDeclined = "Your location is required or add city manually";
}
