//
//  ViewController.swift
//  project2
//
//  Created by Ashika Trambadiya on 2023-07-25.
//

import UIKit
import CoreLocation

struct WeatherApiResponse: Codable {
    let location: Location
    let current: CurrentWeather
}

struct Location: Codable {
    let name: String
}

struct CurrentWeather: Codable {
    let temp_c: Double
    let temp_f: Double
    let condition: Condition
}

struct Condition: Codable {
    let text: String
    let code: Int
}


class ViewController: UIViewController, UISearchBarDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationButton: UIButton!
    
    @IBOutlet weak var temperatureLabel: UILabel!
    
    @IBOutlet weak var weatherConditionLabel: UILabel!
    
    @IBOutlet weak var weatherIconImageView: UIImageView!
    
    @IBOutlet weak var temperatureUnitSwitch: UISwitch!
    
    private let locationManager = CLLocationManager()
    private var weatherData: WeatherData?
    private var isTemperatureInCelsius = true
    
    private let apiKey = "af317184cf164ed48f1225825232607"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        searchBar.delegate = self
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    
    @IBAction func locationButtonTapped(_ sender: UIButton) {
        
        print("Login button tapped")
        locationManager.startUpdatingLocation()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        let status = manager.authorizationStatus
        print("Current location status \(status.rawValue)")
        switch status.rawValue {
        case 3, 4:
            // Start updating the location
            locationManager.startUpdatingLocation()
        case 0:
            //Location is not determined yet. again request it
            locationManager.requestWhenInUseAuthorization()
        case 1, 2:
            //Ask for permission
            locationManager.requestWhenInUseAuthorization()
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        print("Latitude: \(latitude), Longitude: \(longitude)")
        
        // Once the location is obtained, stop updating location to save battery
        locationManager.stopUpdatingLocation()
        
        fetchWeatherData(for: latitude, and: longitude)
        
    }
    
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text, !searchText.isEmpty else {
            return
        }
        
        // Use geocoding to get the location coordinates from the city name
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(searchText) { placemarks, error in
            if let error = error {
                // Handle geocoding error
                print("Geocoding error: \(error.localizedDescription)")
                return
            }
            
            guard let location = placemarks?.first?.location else {
                // Handle invalid location data
                return
            }
            
            // Fetch weather data for the obtained location coordinates
            //            self.fetchWeatherData(for: location.coordinate.latitude, and: location.coordinate.longitude)
        }
        
        searchBar.resignFirstResponder()
    }
    
    
    @IBAction func temperatureUnitSwitchValueChanged(_ sender: UISwitch) {
        isTemperatureInCelsius = sender.isOn
        if let weatherData = weatherData {
            updateTemperatureLabel(with: weatherData)
        }
    }
    
    func fetchWeatherData(for latitude: Double, and longitude: Double) {
        
        let baseUrl = "https://api.weatherapi.com/v1/current.json"
        let urlString = "\(baseUrl)?key=\(apiKey)&q=\(latitude),\(longitude)"
        
        print(urlString)
        guard let url = URL(string: urlString) else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error in API: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("Error: Data is empty.")
                return
            }
            
            let decoder = JSONDecoder()
            
            do {
                let weatherResponse: WeatherApiResponse = try decoder.decode(WeatherApiResponse.self, from: data)
                
                print(weatherResponse.location)
                print(weatherResponse.current)
                
                let location = weatherResponse.location
                let current = weatherResponse.current
                
                self.updateUI(location: location, current: current)
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    
    func updateUI(location: Location, current: CurrentWeather) {
        DispatchQueue.main.async {
            self.locationLabel.text = location.name
            self.weatherConditionLabel.text = String(current.condition.text)
            self.temperatureLabel.text = String(current.temp_c)
            self.changeImage(code: current.condition.code)
        }
        //        locationLabel.text = weatherData.locationName
        //        updateTemperatureLabel(with: weatherData)
        //        weatherConditionLabel.text = weatherData.weatherCondition
        //        weatherIconImageView.image = UIImage(systemName: "\(weatherData.weatherIconCode).circle")
        //        weatherIconImageView.tintColor = UIColor.systemOrange
    }
    
    func changeImage(code: Int) {
        //Change image based on given code
        let config = UIImage.SymbolConfiguration(paletteColors: [.systemBlue, .systemYellow])
        self.weatherIconImageView.preferredSymbolConfiguration = config
        switch code {
        case 1000:
            self.weatherIconImageView.image = UIImage(systemName: "cloud.sun")
        case 1003, 1006:
            self.weatherIconImageView.image = UIImage(systemName: "cloud.circle")
        case 1063, 1180, 1183, 1186, 1189, 1192, 1195, 1198, 1201, 1240, 1243, 1246, 1273, 1276:
            self.weatherIconImageView.image = UIImage(systemName: "cloud.rain")
        case 1009, 1030:
            self.weatherIconImageView.image = UIImage(systemName: "cloud.fill")
        case 1135, 1147:
            self.weatherIconImageView.image = UIImage(systemName: "cloud.fog")
        default:
            self.weatherIconImageView.image = UIImage(systemName: "cloud")
        }
    }
    
    func updateTemperatureLabel(with weatherData: WeatherData) {
        if isTemperatureInCelsius {
            temperatureLabel.text = "\(weatherData.temperatureCelsius)°C"
        } else {
            temperatureLabel.text = "\(weatherData.temperatureFahrenheit)°F"
        }
    }
    
    //HELPER METHODS
    func openAppSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
        
        if UIApplication.shared.canOpenURL(settingsURL) {
            UIApplication.shared.open(settingsURL)
        }
    }
    
}


