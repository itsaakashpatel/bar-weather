//
//  CityViewController.swift
//  project2
//
//  Created by Priyal Shah on 2023-08-02.
//

import UIKit

class CityViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var cityListTableView: UITableView!
    
    var cityListName = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cityListTableView.delegate = self
        cityListTableView.dataSource = self
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        5 // cityListName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CityTableViewCell", for: indexPath) as? CityTableViewCell
        else {
            return UITableViewCell()
        }
        cell.cityName.text = "London" + " 13C" // cityListName[indexPath.row]  + "Temp "
        cell.weatherImageView.image = UIImage(systemName: "cloud.sun.fill", withConfiguration: UIImage.SymbolConfiguration.preferringMulticolor())
        return cell
    }
    
}
