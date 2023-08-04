//
//  CityViewController.swift
//  project2
//
//  Created by Priyal Shah on 2023-08-02.
//

import UIKit

class CityViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var cityListTableView: UITableView!
    
    var finalLocations: [String: LocationInfo] = [:]
    var isTemperatureInCelsius = true
    var newDataSource = [LocationInfo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cityListTableView.delegate = self
        cityListTableView.dataSource = self
        finalLocations.forEach { data in
            newDataSource.append(data.value)
        }
        print("isTemperatureInCelsius \(isTemperatureInCelsius)")
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        newDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CityTableViewCell", for: indexPath) as? CityTableViewCell
        else {
            return UITableViewCell()
        }
        let cityName = newDataSource[indexPath.row].name
        let cityTemp = newDataSource[indexPath.row].tempC
        let cityTempInF = newDataSource[indexPath.row].tempF
        cell.cityName.text =  cityName + " " + "\(isTemperatureInCelsius ? cityTemp : cityTempInF)" + "\(isTemperatureInCelsius ? " C" : " F")"
        cell.weatherImageView.image = changeImage(code:  newDataSource[indexPath.row].code)
        return cell
    }
    
    func changeImage(code: Int) -> UIImage? {
        //Change image based on given code
        let config = UIImage.SymbolConfiguration(paletteColors: [.systemBlue, .systemYellow])
        switch code {
        case 1000:
            return UIImage(systemName: "cloud.sun", withConfiguration: config)
        case 1003, 1006:
            return UIImage(systemName: "cloud.circle", withConfiguration: config)
        case 1063, 1180, 1183, 1186, 1189, 1192, 1195, 1198, 1201, 1240, 1243, 1246, 1273, 1276:
            return UIImage(systemName: "cloud.rain", withConfiguration: config)
        case 1009, 1030:
            return UIImage(systemName: "cloud.fill", withConfiguration: config)
        case 1135, 1147:
            return UIImage(systemName: "cloud.fog", withConfiguration: config)
        default:
            return UIImage(systemName: "cloud", withConfiguration: config)
        }
    }
}
