//
//  WeatherForecastApp.swift
//  WeatherForecast
//
//  Created by Mustafa Taşdemir on 22.04.2022.
//

import SwiftUI

@main
struct WeatherForecastApp: App {
    @StateObject private var locations = LocationViewModel()
    var body: some Scene {
        WindowGroup {
            //LocationsView()
            ForecastView(city: locations.locations.activeLocation)
                .environmentObject(locations)
        }
    }
}
