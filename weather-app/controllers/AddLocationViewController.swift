//
//  AddLocationController.swift
//  weather-app
//
//  Copyright © 2021 semra. All rights reserved.
//

import Foundation
import UIKit

class AddLocationViewController : UIViewController {
    
    @IBOutlet weak var searchText: UITextField!
    
    @IBOutlet weak var searchButton: UIButton!
     
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    weak var weatherDelegate: WeatherViewControllerDelegate?;
    
    var weatherManager: WeatherManagerProtocol = WeatherManager();
    
    override func viewDidLoad() {
        super.viewDidLoad();
        setupViewConfigs();
        setupGestures();
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        statusLabel.isHidden = true;
    }
    
    private func setupViewConfigs(){
        view.backgroundColor = UIColor.init(white: 0.5, alpha: 0.6);
        searchText.becomeFirstResponder();
        searchButton.layer.cornerRadius = 5
        searchButton.layer.borderWidth = 1
        searchButton.layer.borderColor = UIColor.green.cgColor
    }
    
    private func setupGestures(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissLocationView))
        tapGesture.delegate = self;
        view.addGestureRecognizer(tapGesture);
    }
    @objc private func dismissLocationView(){
        dismiss(animated: true, completion: nil);
    }
    @IBAction func searchButtonTapped(_ sender: Any) {
        guard let searchedCity = searchText.text, !searchedCity.isEmpty else {return showError(error: ErrorMessages.emptySearchText)};
        statusLabel.isHidden = true;
        searchLocation(city: searchedCity);
        
    }
    
    private func showError(error: String){
        indicatorView.stopAnimating()
        statusLabel.isHidden = false;
        statusLabel.text = error;
        statusLabel.textColor = .red;
    }
    
    private func searchLocation(city: String){
        view.endEditing(true);
        indicatorView.startAnimating();
        weatherManager.fetchWeather(city: city) { [weak self](result) in
            guard let self = self else {return}
            switch(result){
            case .success(let weatherData):
                self.handleResult(model: weatherData)
            case .failure(let error):
                self.showError(error: error.localizedDescription)
            }
        }
    }
    
    private func handleResult(model: WeatherModel) {
        indicatorView.stopAnimating();
        statusLabel.isHidden = false;
        statusLabel.text = "SUCCESS";
        statusLabel.textColor = .green
        DispatchQueue.main.asyncAfter(deadline: .now()+1.0) { [weak self] in
            guard let self = self else{return}
            self.weatherDelegate?.updateWeatherAfterSearch(model: model);
        }
        
    }
}

extension AddLocationViewController : UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view == self.view;
    }
}
