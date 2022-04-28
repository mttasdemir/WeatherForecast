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
    @State private var searchCity: String = "aa"
    let linearGradient = LinearGradient(colors: [.clear, .blue], startPoint: .top, endPoint: .bottom)

    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                linearGradient
                    .opacity(0.6)
                    .ignoresSafeArea()
                VStack {
                    if searchCity.count >= 3 {
                        ForEach(model.searchCities(for: searchCity)) { city in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(.blue)
                                    .frame(maxHeight: 40)
                                Text("\(city.name), \(city.countryName)").font(.title2)
                                    .foregroundColor(.white)
                                    .padding(.leading)
                            }
                            .padding([.leading, .trailing])
                            .padding(.bottom, -7)
                        }
                    } else {
                        ForEach(model.locations.locations) { city in
                            ZStack(alignment: .top) {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(.blue)
                                    .frame(maxHeight: 90)
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(city.name).font(.title)
                                            .padding(.bottom, 5)
                                        Text("Mostly Clear").font(.system(size: 15))
                                    }
                                    Spacer()
                                    Text("30\u{00B0}").font(.system(size: 40))
                                }
                                .padding()
                            }
                            .padding([.leading, .trailing])
                            .padding(.bottom, -7)
                        }
                    }

                }
                .searchable(text: $searchCity, prompt: Text("Search for a city"))
                .navigationTitle("Weather")
            }
        }
    }
}


struct LocationsView_Preview: PreviewProvider {
    static var previews: some View {
        LocationsView()
            .environmentObject(LocationViewModel())
    }
}
