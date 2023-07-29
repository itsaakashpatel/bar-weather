//
//  WeatherData.swift
//  project2
//
//  Created by Ashika Trambadiya on 2023-07-26.
//

import Foundation
struct WeatherData: Codable {
    let locationName: String
    let temperatureCelsius: Double
    let temperatureFahrenheit: Double
    let weatherCondition: String
    let weatherIconCode: Int // You can use this code to map to SF Symbols
}
