//
//  Urls.swift
//  WeatherForecast
//
//  Created by Mustafa Taşdemir on 25.04.2022.
//

import Foundation

struct Urls {
    static let baseUrl = "http://dataservice.accuweather.com"
    
    static func forecastUrl(for city: City) -> URL? {
        let url = baseUrl + "/forecasts/v1/hourly/12hour/\(city.key)?apikey=nUHFfKAvAh2kCFU5FqeIDM5a0iC5vuje&details=true"
        return URL(string: url)
    }
    
    static func citySearchUrl(for searchKey: String) -> URL? {
        let url = baseUrl + "/locations/v1/cities/search?apikey=nUHFfKAvAh2kCFU5FqeIDM5a0iC5vuje&q=\(searchKey)"
        return URL(string: url)
    }
}
