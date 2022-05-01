//
//  Location.swift
//  WeatherForecast
//
//  Created by Mustafa Taşdemir on 25.04.2022.
//

import Foundation

struct Location {
    var activeLocation: City
    var locations: Array<City>
}

extension Location {
    static let sampleData: Location = Location(activeLocation: City.sampleData!, locations: [City.sampleData!])
}
