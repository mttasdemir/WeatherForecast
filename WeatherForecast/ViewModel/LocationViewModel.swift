//
//  LocationViewModel.swift
//  WeatherForecast
//
//  Created by Mustafa Taşdemir on 25.04.2022.
//

import Foundation
import UIKit
import Combine

class LocationViewModel: ObservableObject {
    @Published var locations: Location = Location.sampleData
    
    // MARK: - Intent
    
    func forecast(for city: City) async throws -> Array<Forecast> {
        guard let url = Urls.forecastUrl(for: city) else { throw GeneralError.invalidUrl }
        
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
    
    // MARK: - Publisher verison
    @Published var weatherForecast: (forecasts: Array<Forecast>?, error: Error?) = ([], nil)
    private var cancellable: AnyCancellable? = nil
    
    func forecastp(for city: City) {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = JSONDecoder.DateDecodingStrategy.iso8601
        
        cancellable =
        URLSession.shared
            .dataTaskPublisher(for: Urls.forecastUrl(for: city)!)
            .tryMap { output in
                guard (output.response as? HTTPURLResponse)?.statusCode == 200 else {
                    throw GeneralError.invalidServerResponse
                }
                return output.data
            }
            .decode(type: Array<Forecast>.self, decoder: jsonDecoder)
            .mapError{ _ in GeneralError.invalidServerResponse }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    self.weatherForecast = (nil, error)
                }
            }, receiveValue: { result in
                self.weatherForecast = (result, nil)
            })
    }
    
}
