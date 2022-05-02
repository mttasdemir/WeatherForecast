//
//  Forecast.swift
//  WeatherForecast
//
//  Created by Mustafa Taşdemir on 22.04.2022.
//

import Foundation

struct Forecast: Decodable, Hashable, Identifiable {
    //http://dataservice.accuweather.com/forecasts/v1/hourly/12hour/318251?apikey=nUHFfKAvAh2kCFU5FqeIDM5a0iC5vuje&details=true
    var id: Int {
        self.epochDateTime
    }
    var date: Date
    var epochDateTime: Int
    var weatherIcon: Int
    var iconPhrase: String
    var temperature: Temperature
    
    enum CodingKeys: String, CodingKey {
        case epochDateTime = "EpochDateTime"
        case weatherIcon = "WeatherIcon"
        case iconPhrase = "IconPhrase"
        case temperature = "Temperature"
        case date = "DateTime"
    }
    
    struct Temperature: Decodable, Hashable {
        var value: Int
        var unit: Unit
        
        enum CodingKeys: String, CodingKey {
            case value = "Value"
            case unit = "Unit"
        }
    }
    
    enum Unit: String, Decodable, CaseIterable{
        case F = "F", C = "C"
    }

    var epochAsDate: Date {
        Date(timeIntervalSince1970: TimeInterval(epochDateTime))
    }
    
    var hour: Int {
        Calendar(identifier: Calendar.Identifier.gregorian).dateComponents([.hour], from: self.date).hour!
    }
    
    func temperature(in unit: Unit) -> Int {
        switch unit {
        case .F: return temperature.value
        case .C: return (temperature.value - 32) * 5 / 9
        }
    }
}

extension Forecast {
    static let sampleData: Array<Forecast> = {
        do {
            let fileUrl = Bundle.main.url(forResource: "SampleForecast", withExtension: "json")!
            let jsonData = try FileHandle(forReadingFrom: fileUrl).availableData
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy =  JSONDecoder.DateDecodingStrategy.iso8601
            return try decoder.decode(Array<Forecast>.self, from: jsonData)
        } catch {
            return []
        }
    }()
}

extension Forecast {
    static let empty: Forecast = Forecast(date: Date.now, epochDateTime: 0, weatherIcon: 1, iconPhrase: "", temperature: Temperature(value: 0, unit: .F))
}
