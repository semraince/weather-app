//
//  ViewController.swift
//  weather-app
//
//  Copyright © 2021 semra. All rights reserved.
//

import UIKit
import SkeletonView

protocol WeatherViewControllerDelegate : class {
    func updateWeatherAfterSearch(model: WeatherModel) -> Void
}

class WeatherViewController: UIViewController {

    @IBOutlet weak var conditionImageView: UIImageView!
    
    @IBOutlet weak var temperatureLabel: UILabel!
    
    @IBOutlet weak var conditionLabel: UILabel!
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    let weatherManager : WeatherManagerProtocol = WeatherManager();
    
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

