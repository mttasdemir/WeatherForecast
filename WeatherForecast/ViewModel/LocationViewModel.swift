//
//  LocationViewModel.swift
//  WeatherForecast
//
//  Created by Mustafa Taşdemir on 25.04.2022.
//

import Foundation
import SwiftUI
import UIKit
import Combine

class LocationViewModel: ObservableObject {
    @Published var locations: Location = Location.sampleData
    
    func addCity(_ city: City) {
        locations.locations.append(city)
    }
    
    // MARK: - Intent
    
    func updateCityForecast() async {
        for city in locations.locations {
            if let index = locations.locations.firstIndex(where: { $0.id == city.id }) {
                let forecast = try? await currentForecast(of: city).first
                DispatchQueue.main.async {
                    self.locations.locations[index].forecast = forecast
                }
            }
        }
    }
    
    func currentForecast(of city: City) async throws -> Array<Forecast> {
        guard let url = Urls.currentForecastUrl(for: city) else { throw GeneralError.invalidUrl }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw GeneralError.invalidServerResponse }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = JSONDecoder.DateDecodingStrategy.iso8601
        return try decoder.decode(Array<Forecast>.self, from: data)
        
    }
    
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
    
    @Published var cities: (cities: Array<City>?, error: Error?) = (nil, nil)
    @MainActor
    func searchCities(for key: String) async {
        guard let url = Urls.citySearchUrl(for: key) else {
            self.cities = (nil, GeneralError.invalidUrl)
            return
        }
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                self.cities = (nil, GeneralError.invalidUrl)
                return
            }
            let cities = try JSONDecoder().decode(Array<City>.self, from: data)
            self.cities = (cities, nil)
        }
        catch {
            self.cities = (nil, error)
        }
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
