//
//  ViewController.swift
//  weather-app
//
//  Copyright © 2021 semra. All rights reserved.
//

import UIKit
import SkeletonView
import CoreLocation

protocol WeatherViewControllerDelegate : class {
    func updateWeatherAfterSearch(model: WeatherModel) -> Void
}

class WeatherViewController: UIViewController {

    @IBOutlet weak var conditionImageView: UIImageView!
    
    @IBOutlet weak var temperatureLabel: UILabel!
    
    @IBOutlet weak var conditionLabel: UILabel!
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    let weatherManager : WeatherManagerProtocol = WeatherManager();
    
    lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager();
        manager.delegate = self;
        return manager;
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        weatherManager.fetchWeather(city: "Istanbul") { [weak self ](result) in
            guard let self = self else {return}
            switch(result) {
            case .success(let data):
                self.updateView(model: data)
            case .failure(let error):
                self.updateViewWithError();
            }
            
        }
        showAnimation();
        
    }
    
    private func updateView(model: WeatherModel){
        self.stopHideAnimation();
        DispatchQueue.main.async {[weak self] in
            guard let self = self else {return}
            self.temperatureLabel.text = model.temp.toString().appending("°C")
            self.conditionLabel.text = model.conditionDescription;
            self.navigationItem.title = model.countryName;
            switch(model.conditionImageName){
            case "none":
                self.conditionImageView.image = UIImage(systemName: "xmark")
            default:
                self.conditionImageView.image = UIImage(named: model.conditionImageName)
            }
            
        }
        
    }
    
    private func updateViewWithError(){
        self.stopHideAnimation();
        self.conditionImageView.image = UIImage(named: "imSad")
        self.conditionLabel.text = ErrorMessages.unableToHandleRequest
        self.conditionLabel.textAlignment = .center
        self.conditionLabel.font = conditionLabel.font.withSize(15)
    }


    @IBAction func addLocationButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "showAddCity", sender: nil);
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAddCity" {
            if let destination = segue.destination as? AddLocationViewController {
                destination.weatherDelegate = self;
            }
        }
    }
    
    
    @IBAction func locationButtonTapped(_ sender: Any) {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways,.authorizedWhenInUse:
            locationManager.requestLocation()
        case .notDetermined :
            locationManager.requestWhenInUseAuthorization();
            locationManager.requestLocation()
        default:
            showAlertForLocationPermission();
        }
    }
    
    private func showAlertForLocationPermission() {
        let title = "Location cannot be accessed"
        let message = "Please enable location permission in settings";
        let alert = UIAlertController (title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil);
        let enableAction = UIAlertAction(title: "Open Settings", style: .default) { _ in
            guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {return}
            if UIApplication.shared.canOpenURL(settingsURL){
                if #available(iOS 10.0, *){
                    UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
                    
                }
                else{
                    UIApplication.shared.openURL(settingsURL);
                }
            }
        }
        alert.addAction(enableAction);
        alert.addAction(cancelAction);
        
        present(alert, animated: true, completion: nil);
    }
    private func stopHideAnimation(){
        conditionImageView.hideSkeleton();
        temperatureLabel.hideSkeleton();
        conditionLabel.hideSkeleton();
    }
    private func showAnimation(){
        conditionImageView.showAnimatedGradientSkeleton();
        temperatureLabel.showAnimatedGradientSkeleton();
        conditionLabel.showAnimatedGradientSkeleton();
        
    }
}

extension WeatherViewController: WeatherViewControllerDelegate {
    func updateWeatherAfterSearch(model: WeatherModel) {
        presentedViewController?.dismiss(animated: true, completion: { [weak self] in
            guard let self = self else {return}
            self.updateView(model: model);
        })
        
    }
}

extension WeatherViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationManager.stopUpdatingLocation();
            let lat = location.coordinate.latitude;
            let lng = location.coordinate.longitude;
            weatherManager.fetchWeather(lat: lat, lng: lng) { [weak self] (result) in
                guard let self = self else {return}
                switch(result){
                case .success(let data):
                    self.updateView(model: data)
                case .failure(let error):
                    self.updateViewWithError();
                    
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
    }
}

