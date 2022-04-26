//
//  LocationViewModel.swift
//  WeatherForecast
//
//  Created by Mustafa Taşdemir on 25.04.2022.
//

import Foundation

class LocationViewModel: ObservableObject {
    @Published var locations: Location = Location.sampleData
    
    // MARK: - Intent
    
    func forecast(for location: City) async throws -> Array<Forecast> {
        guard let url = Urls.forecastUrl(for: location) else { throw GeneralError.invalidUrl }
        
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let response = response as? HTTPURLResponse,
              response.statusCode == 200 else {
                  throw GeneralError.invalidServerResponse
              }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = JSONDecoder.DateDecodingStrategy.iso8601
        return try decoder.decode(Array<Forecast>.self, from: data)
        
    }
    
    
    func searchCities(for key: String) -> Array<City> {
        [locations.activeLocation, locations.activeLocation]
    }
    
}
