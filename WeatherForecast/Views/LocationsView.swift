//
//  LocationsView.swift
//  WeatherForecast
//
//  Created by Mustafa Taşdemir on 26.04.2022.
//

import Foundation
import SwiftUI

struct LocationsView: View {
    @EnvironmentObject var model: LocationViewModel
    @State private var searchCity: String = ""
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                List {
                    if searchCity.count >= 3 {
                        ForEach(model.searchCities(for: searchCity)) { city in
                            Text("\(city.name), \(city.countryName)")
                        }
                    } else {
                        ForEach(model.locations.locations) { city in
                            Text(city.name)
                        }
                    }
                }
            }
            .navigationTitle("Weather")
            .searchable(text: $searchCity, prompt: Text("Search for a city"))
        }
    }
}


struct LocationsView_Preview: PreviewProvider {
    static var previews: some View {
        LocationsView()
            .environmentObject(LocationViewModel())
    }
}
