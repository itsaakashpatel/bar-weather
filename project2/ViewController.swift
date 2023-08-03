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

struct SearchApiResponse: Codable {
    let lat: Double
    let lon: Double
    let name: String
    let region: String
}

struct LocationInfo {
    let name: String
    let tempC: Double
    let tempF: Double
    let code: Int
    let condition: String
}

class ViewController: UIViewController, UISearchBarDelegate,UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationButton: UIButton!
    
    @IBOutlet weak var temperatureLabel: UILabel!
    
    @IBOutlet weak var weatherConditionLabel: UILabel!
    
    @IBOutlet weak var weatherIconImageView: UIImageView!
    
    @IBOutlet weak var searchTableView: UITableView!
    
    @IBOutlet weak var searchIcon: UIButton!
    private let locationManager = CLLocationManager()
    private var weatherData: WeatherData?
    private var isTemperatureInCelsius = true
    private var tempInCal = ""
    
    private let apiKey = "af317184cf164ed48f1225825232607"
    
    private var searchResults: [String] = []
    
    private var finalLocations: [String: LocationInfo] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        searchBar.delegate = self
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        searchTableView.delegate = self
        searchTableView.dataSource = self
        searchTableView.isHidden = true
        
    }
    
    @IBAction func locationButtonTapped(_ sender: UIButton) {
        locationManager.startUpdatingLocation()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gotoCity" {
            guard let vc = segue.destination as? CityViewController else { return }
            vc.cityListName = [] // ADD CITY NAME
        }
    }
  
    @IBAction func searchTapped(_ sender: Any) {
        fetchWeatherData(for: nil, and: nil, loc: searchBar.text)
        searchTableView.isHidden = true
        searchBar.text = ""
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
        
        //Stop table for search view and clear search text if any
        searchTableView.isHidden = true
        searchBar.text = ""
        
        fetchWeatherData(for: latitude, and: longitude, loc: "")
        
    }
    
    
    
    func searchBarSearchButtonClicked() {
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
            
        }
        
        searchBar.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("searchResults \(searchResults.count)")
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultCell", for: indexPath)
                cell.textLabel?.text = searchResults[indexPath.row]
                return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let selectedResult = searchResults[indexPath.row]
            //  update the search bar text with the selected suggestion
            searchBar.text = selectedResult
        searchTableView.isHidden = true
        fetchWeatherData(for: nil, and: nil, loc: selectedResult)
        }
    
    
    @IBAction func unitSwitchValueChanged(_ sender: UISegmentedControl) {
        print("Value \(sender.selectedSegmentIndex)")
        
        if let currentTemp = Double(tempInCal) {
            print("Current temp \(currentTemp)")
            if sender.selectedSegmentIndex == 0 { // Celsius to Fahrenheit
                temperatureLabel.text = String(currentTemp * 9/5 + 32)
            } else { // Fahrenheit to Celsius
                temperatureLabel.text = String(currentTemp)
            }
        } else {
            print("Something is wrong")
            return
        }
    }
    
    func encodeURL(url : String) -> String? {
        let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~")
        return url.addingPercentEncoding(withAllowedCharacters: allowedCharacters)
    }
    
    func fetchWeatherData(for latitude: Double?, and longitude: Double?, loc location: String?) {
        
        var urlString = ""
        let baseUrl = "https://api.weatherapi.com/v1/current.json"
        if let latitude = latitude, let longitude = longitude {
            urlString = "\(baseUrl)?key=\(apiKey)&q=\(latitude),\(longitude)"
        } else if let loc = location, let location = encodeURL(url:loc) {
            urlString = "\(baseUrl)?key=\(apiKey)&q=\(location)"
        }
        
        guard let url = URL(string: urlString) else {
            return
        }
        
        print("\(urlString)")
        
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
                
                //push to final locations array
                let itemId = weatherResponse.location.name.lowercased()
                let locationData = LocationInfo( name: weatherResponse.location.name, tempC: weatherResponse.current.temp_c, tempF: weatherResponse.current.temp_f, code: weatherResponse.current.condition.code, condition: weatherResponse.current.condition.text)
                
                self.finalLocations[itemId] = locationData
                
                let location = weatherResponse.location
                let current = weatherResponse.current
                
                print("final locations counts \(self.finalLocations.count) , \(self.finalLocations)")
                
                self.updateUI(location: location, current: current)
                
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Make sure to cancel previous autocomplete requests to avoid multiple calls
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(fetchAutocompleteSuggestions(_:)), object: searchBar)
        
        // Delay the autocomplete request to avoid making API calls on every keystroke
        self.perform(#selector(fetchAutocompleteSuggestions(_:)), with: searchBar, afterDelay: 0.5)
        
        searchTableView.reloadData()
        searchTableView.isHidden = searchResults.isEmpty
    }
    
    @objc func fetchAutocompleteSuggestions(_ searchBar: UISearchBar) {
        
        print("Search func called")
        
        let autocompleteBaseUrl = "https://api.weatherapi.com/v1/search.json"
        
        guard let searchText = searchBar.text, !searchText.isEmpty else {
            return
        }
        
        let urlString = "\(autocompleteBaseUrl)?key=\(apiKey)&q=\(searchText)"
        
        print("Search url string \(urlString)")
        
        guard let url = URL(string: urlString) else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error in autocomplete API: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("Error: Data is empty.")
                return
            }
            
            let decoder = JSONDecoder()
            
            do {
                let weatherResponse: [SearchApiResponse] = try decoder.decode([SearchApiResponse].self, from: data)
                
                var searchData: [String] = []
                
                for item in weatherResponse {
                    searchData.append(item.name + ", " + item.region)
                }
                
                print("Seaarch data \(searchData)")
                
                // Update the search bar's suggestions list
                DispatchQueue.main.async {
                    self.searchResults = searchData
                    self.searchTableView.reloadData()
                }
            } catch {
                print("Error parsing autocomplete JSON: \(error.localizedDescription)")
            }
            
        }.resume()
        
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
    
    func updateUI(location: Location, current: CurrentWeather) {
        DispatchQueue.main.async {
            self.locationLabel.text = location.name
            self.weatherConditionLabel.text = String(current.condition.text)
            self.temperatureLabel.text = String(current.temp_c)
            self.changeImage(code: current.condition.code)
            self.tempInCal = String(current.temp_c)
        }
    }
    
}

