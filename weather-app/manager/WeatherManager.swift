//
//  WeatherManager.swift
//  weather-app
//
//  Copyright © 2021 semra. All rights reserved.
//

import Foundation
import Alamofire


public protocol WeatherManagerProtocol: class {
    func fetchWeather(city: String, completionHandler: @escaping (Result<WeatherModel,Error>)->Void)
}

class WeatherManager : WeatherManagerProtocol {
    private let API_KEY = "6622c027e3f1b8df743cdb0c8c0b43e1";
    
    
    func fetchWeather(city: String, completionHandler: @escaping (Result<WeatherModel,Error>)->Void ){
        
        let cityQuery = city.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? city;
        let url = "https://api.openweathermap.org/data/2.5/weather?q=%@&appid=%@&units=metric"
        let urlString = String(format: url, cityQuery, API_KEY);
        print("\(urlString)")
        
        AF.request(urlString)
            .validate()
            .responseDecodable(of: WeatherData.self, queue: .main, dataPreprocessor: JSONResponseSerializer.defaultDataPreprocessor, decoder: JSONDecoder(), emptyResponseCodes: JSONResponseSerializer.defaultEmptyResponseCodes, emptyRequestMethods: JSONResponseSerializer.defaultEmptyRequestMethods) { [weak self]
            (response) in
            
            switch response.result {
            case .success(let data) :
                completionHandler(.success(data.weatherModel))
            case .failure(let error) :
                if let err = self?.getWeatherDataError(error: error, data: response.data) {
                    completionHandler(.failure(err));
                }
                else{
                    completionHandler(.failure(WeatherError.unknown));
                }
            }
        }
        
    }
    
    private func getWeatherDataError(error: AFError, data: Data? ) -> Error? {
        if error.responseCode == 404, let data = data, let failure = try? JSONDecoder().decode(WeatherDataFailure.self, from: data) {
            return WeatherError.customDescription(failure.message);
        }
        else {
            return nil;
        }
    }
}
