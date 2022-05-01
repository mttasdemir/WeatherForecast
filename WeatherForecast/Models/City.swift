//
//  City.swift
//  WeatherForecast
//
//  Created by Mustafa Taşdemir on 23.04.2022.
//

import Foundation
import SwiftUI

struct City: Identifiable, Decodable {

    //http://dataservice.accuweather.com/locations/v1/cities/search?apikey=nUHFfKAvAh2kCFU5FqeIDM5a0iC5vuje&q=Kon
    var id: String {
        self.key
    }
    var key: String
    var name: String
    var cityArea: String
    var countryId: String
    var countryName: String
    var geoPosition: GeoPosition
    var forecast: Forecast?
    
    enum CodingKeys: String, CodingKey {
        case key = "Key", name = "LocalizedName", geoPosition = "GeoPosition",
             Country, AdministrativeArea
    }
    
    enum CountryKeys: String, CodingKey {
        case countryName = "LocalizedName", countryId = "ID"
    }
    
    enum AdministrativeAreaKeys: String, CodingKey {
        case cityArea = "LocalizedName"
    }
    
    struct GeoPosition: Decodable {
        var latitude: Double
        var longitude: Double
        
        enum CodingKeys: String, CodingKey {
            case latitude = "Latitude", longitude = "Longitude"
        }
    }
    
    init() {
        self.key = ""
        self.name = ""
        self.cityArea = ""
        self.countryId = ""
        self.countryName = ""
        self.geoPosition = GeoPosition(latitude: 0, longitude: 0)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.key = try container.decode(String.self, forKey: .key)
        self.name = try container.decode(String.self, forKey: .name)
        let countryContainer = try container.nestedContainer(keyedBy: CountryKeys.self, forKey: .Country)
        self.countryName = try countryContainer.decode(String.self, forKey: .countryName)
        self.countryId = try countryContainer.decode(String.self, forKey: .countryId)
        self.geoPosition = try container.decode(GeoPosition.self, forKey: .geoPosition)
        let cityAreaContainer = try container.nestedContainer(keyedBy: AdministrativeAreaKeys.self, forKey: .AdministrativeArea)
        self.cityArea = try cityAreaContainer.decode(String.self, forKey: .cityArea)
    }

}

extension City {
    static let sampleData: City? = {
        do {
            let fileUrl = Bundle.main.url(forResource: "SampleCity", withExtension: "json")!
            let jsonData = try FileHandle(forReadingFrom: fileUrl).availableData
            return try JSONDecoder().decode(Array<City>.self, from: jsonData).first
        } catch {
            return nil
        }
    }()
}
