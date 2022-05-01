//
//  ForecastView.swift
//  WeatherForecast
//
//  Created by Mustafa Taşdemir on 22.04.2022.
//

import SwiftUI
import MapKit

struct ForecastView: View {
    @EnvironmentObject var model: LocationViewModel
    @State private var forecasts: Array<Forecast> = []
    @State private var coordinates = MKCoordinateRegion()
    @State private var city: City
    let showToolbar: Bool
    let linearGradient = LinearGradient(colors: [.blue, .cyan], startPoint: .top, endPoint: .bottom)
    @State private var didError: Bool = false
    @State private var errorMessage: String = ""
    
    init(city: City, showToolbar: Bool) {
        self.showToolbar = showToolbar
        self._city = State(initialValue: city)
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                if forecasts.isEmpty {
                    ProgressView().scaleEffect(2.0)
                } else {
                    linearGradient
                        .opacity(0.6)
                    VStack {
                        VStack {
                            Text(city.name)
                            Text("\(forecasts.first!.temperatureInCelcius)\u{00B0}")
                            Text("\(forecasts.first!.iconPhrase)")
                                .font(.system(size: 20))
                                .padding(.trailing, 15)
                        }
                        .padding(.top, 80)
                        .font(.system(size: 60))
                        
                        Section {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(forecasts) { forecast in
                                        VStack {
                                            Text(forecast.hour, format: .twoDigitNumber)
                                            Image(String(forecast.weatherIcon))
                                            Text("\(forecast.temperatureInCelcius)\u{00B0}")
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.all, 5)
                        .background(.white.opacity(0.3), in: RoundedRectangle(cornerRadius: 15))
                        
                        Section {
                            Map(coordinateRegion: $coordinates)
                                .onAppear {
                                    coordinates = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: city.geoPosition.latitude, longitude: city.geoPosition.longitude),
                                                                     span: MKCoordinateSpan(latitudeDelta: 0.7, longitudeDelta: 0.7))
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                        }
                        .padding(.bottom, 90)
                    }
                    .toolbar {
                        ToolbarItemGroup(placement: .bottomBar) {
                            if showToolbar {
                                Button {
                                } label: { Image(systemName: "ellipsis.circle") }
                                NavigationLink(destination: LocationsView(activeCity: $city), label: { Image(systemName: "list.bullet")})
                            }
                        }
                    }
                }
            }
            .foregroundColor(.white)
            .ignoresSafeArea()
            .task {
                do {
                    forecasts = try await model.forecast(for: city)
                }
                catch {
                    didError = true
                    errorMessage = error.localizedDescription
                }
            }
            .alert("Error", isPresented: $didError, presenting: errorMessage)
            { _ in
                Button("OK") { didError = false }
            } message: { message in
                Text(message)
                    .font(.body)
            }
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ForecastView(city: City.sampleData!, showToolbar: true)
    }
}
