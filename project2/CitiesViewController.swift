//
//  CitiesViewController.swift
//  project2
//
//  Created by Priyal Shah on 2023-07-29.
//

import UIKit

class CitiesViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var citiesArray = ["New Delhi", "London", "Hong Kong", "Toronto", "New York"]
    var cityData = [2, 34]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        for _ in citiesArray {
            // DO API CALL FOR ALL THE CITY
            
            let dataFound = 8
            
            cityData.append(dataFound)
            DispatchQueue.main.async {
                if self.cityData.count == self.citiesArray.count {
                    self.tableView.reloadData()
                }
            }
        }
    }
}

extension CitiesViewController: UITableViewDelegate,
                                UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return citiesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell =  tableView.dequeueReusableCell(withIdentifier: "CityTableViewCell", for: indexPath) as? CityTableViewCell else { return UITableViewCell() }
        cell.cityNameLabel.text = citiesArray[indexPath.row] + " 24 C"
        return cell
    }
    
    
}
