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
    let tempC: Double
    let tempF: Double
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        searchBar.delegate = self
        locationManager.delegate = self
    }
    
    
    @IBAction func locationButtonTapped(_ sender: UIButton) {
        
        let status = locationManager.authorizationStatus
        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else {
            // Start updating the location
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            guard let location = locations.last else {
                return
            }
            
            // Once the location is obtained, stop updating location to save battery
            locationManager.stopUpdatingLocation()
            
        
      //  fetchWeatherData(for: location.coordinate.latitude, and: location.coordinate.longitude)
        
        }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        let status = manager.authorizationStatus
        if status == .authorizedWhenInUse {
            // If user grants location permission, start updating location
            locationManager.startUpdatingLocation()
        }
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
//             self.fetchWeatherData(for: location.coordinate.latitude, and: location.coordinate.longitude)
         }
         
         searchBar.resignFirstResponder()
     }
    
    
    @IBAction func temperatureUnitSwitchValueChanged(_ sender: UISwitch) {
        isTemperatureInCelsius = sender.isOn
        if let weatherData = weatherData {
            updateTemperatureLabel(with: weatherData)
        }
    }
    
    
    
//    func fetchWeatherData(for latitude: Double, and longitude: Double) {
//        let apiKey = "af317184cf164ed48f1225825232607"
//        let baseUrl = "https://api.weatherapi.com/v1/current.json"
//        let urlString = "\(baseUrl)?key=\(apiKey)&q=\(latitude),\(longitude)"
//
//        guard let url = URL(string: urlString) else {
//            return
//        }
//
//        URLSession.shared.dataTask(with: url) { data, response, error in
//            if let error = error {
//                print("Error: \(error.localizedDescription)")
//                return
//            }
//
//            guard let data = data else {
//                print("Error: Data is empty.")
//                return
//            }
//
//            do {
//                let decoder = JSONDecoder()
//                let weatherResponse = try decoder.decode(WeatherApiResponse.self, from: data)
//
//                if let locationName = weatherResponse.location.name,
//               let temperatureCelsius = weatherResponse.current.tempC,
//               let temperatureFahrenheit = weatherResponse.current.tempF,
//               let weatherCondition = weatherResponse.current.condition.text,
//               let weatherIconCode = weatherResponse.current.condition.code {
//
//                let weatherData = WeatherData(
//                    locationName: locationName,
//                    temperatureCelsius: temperatureCelsius,
//                    temperatureFahrenheit: temperatureFahrenheit,
//                    weatherCondition: weatherCondition,
//                    weatherIconCode: weatherIconCode
//                                )
//
//                    DispatchQueue.main.async {
//                        self.weatherData = weatherData
//                        self.updateUI(with: weatherData)
//                    }
//                } else {
//                    print("Error: Weather data is missing.")
//                }
//            } catch {
//                print("Error parsing JSON: \(error.localizedDescription)")
//            }
//        }.resume()
//    }


        
        
        
    func updateUI(with weatherData: WeatherData) {
            locationLabel.text = weatherData.locationName
            updateTemperatureLabel(with: weatherData)
            weatherConditionLabel.text = weatherData.weatherCondition
            weatherIconImageView.image = UIImage(systemName: "\(weatherData.weatherIconCode).circle")
            weatherIconImageView.tintColor = UIColor.systemOrange
        }

        func updateTemperatureLabel(with weatherData: WeatherData) {
            if isTemperatureInCelsius {
                temperatureLabel.text = "\(weatherData.temperatureCelsius)°C"
            } else {
                temperatureLabel.text = "\(weatherData.temperatureFahrenheit)°F"
            }
        }
        
    }
    

