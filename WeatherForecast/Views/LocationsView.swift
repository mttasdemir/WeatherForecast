//
//  LocationsView.swift
//  WeatherForecast
//
//  Created by Mustafa Taşdemir on 26.04.2022.
//

import Foundation
import SwiftUI

struct LocationsView: View {
    @Environment(\.dismiss) var dismiss: DismissAction
    @Environment(\.dismissSearch) var dismissSearch: DismissSearchAction
    let linearGradient = LinearGradient(colors: [.clear, .blue], startPoint: .top, endPoint: .bottom)
    @EnvironmentObject var model: LocationViewModel
    @Binding var activeCity: City
    @State private var searchCity: String = ""
    @State private var newCity: City = City.sampleData!
    @State private var showNewCity: Bool = false
    @State private var unitType: Forecast.Unit = .C
    
    var body: some View {
        ZStack(alignment: .top) {
            linearGradient
                .opacity(0.6)
                .ignoresSafeArea()
            VStack {
                if searchCity.count >= 4 {
                    if let cities = model.cities.cities,
                       cities.count != 0 {
                        ScrollView {
                            ForEach(cities) { city in
                                SearchResultRow(city: city)
                                    .onTapGesture {
                                        newCity = city
                                        showNewCity = true
                                    }
                            }
                        }
                    } else {
                        VStack {
                            Image(systemName: "magnifyingglass").font(.system(size: 70))
                            Text("No results")
                            if let error = model.cities.error {
                                Text(error.localizedDescription)
                            }
                        }
                    }
                } else {
                    VStack {
                        ForEach(model.locations.locations) { city in
                            CityRow(city: city, unit: unitType)
                                .onTapGesture {
                                    activeCity = city
                                    dismiss()
                                }
                        }
                    }
                    .task {
                        await model.updateCityForecast()
                    }
                }
            }
            .onChange(of: searchCity) { _ in
                if searchCity.count >= 4 {
                    Task {
                        await model.searchCities(for: searchCity)
                    }
                }
            }
            .sheet(isPresented: $showNewCity) {
                ForecastOfNewCity(city: newCity)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Weather")
        .searchable(text: $searchCity, prompt: Text("Search for a city"))
        .toolbar {
            ToolbarItem {
                contextMenu
            }
        }
    }
    
    var contextMenu: some View {
        Menu {
            EditButton()
            Picker("Unit", selection: $unitType) {
                Text("Celsius").tag(Forecast.Unit.C)
                Text("Fahrenheit").tag(Forecast.Unit.F)
            }
        }
        label: { Image(systemName: "ellipsis.circle") }
    }
}


struct LocationsView_Preview: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LocationsView(activeCity: .constant(City.sampleData!))
                .environmentObject(LocationViewModel())
        }
    }
}

struct SearchResultRow: View {
    let city: City
    
    var body: some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .fill(.blue)
                .frame(height: 40, alignment: .leading)
            Text("\(city.name), \(city.cityArea), \(city.countryName)").font(.body)
                .foregroundColor(.white)
                .padding(.leading, 10)
        }
        .padding([.leading, .trailing])
        .padding(.bottom, -5)
    }
}

struct CityRow: View {
    let city: City
    let unit: Forecast.Unit
    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 8)
                .fill(.blue)
                .frame(maxHeight: 90)
            HStack {
                VStack(alignment: .leading) {
                    Text(city.name).font(.title)
                        .padding(.bottom, 5)
                    Text("\(city.forecast?.iconPhrase ?? "-")").font(.system(size: 15))
                }
                Spacer()
                Text("\(city.forecast?.temperature(in: unit) ?? 0)\u{00B0}").font(.system(size: 40))
            }
            .padding()
        }
        .padding([.leading, .trailing])
        .padding(.bottom, -7)
    }
}


struct ForecastOfNewCity: View {
    @Environment(\.dismiss) var dismiss: DismissAction
    @Environment(\.dismissSearch) var dismissSearch: DismissSearchAction
    @EnvironmentObject var model: LocationViewModel

    let city: City
    var body: some View {
        NavigationView {
            ForecastView(city: city, showToolbar: false)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button {
                            dismiss()
                        } label: { Text("Cancel").foregroundColor(.white).fontWeight(.semibold) }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button {
                            dismiss()
                            model.addCity(city)
                            dismissSearch()
                        } label: { Text("Add").foregroundColor(.white).fontWeight(.semibold) }
                    }
            }
        }
    }
}
