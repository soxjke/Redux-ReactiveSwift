//
//  AppState.swift
//  Simple-Weather-App
//
//  Created by Petro Korienev on 10/30/17.
//  Copyright © 2017 Sigma Software. All rights reserved.
//

import Foundation

enum LocationState {
    case notYetRequested
    case notAvailable
    case available
}

enum LocationRequestState {
    case none
    case updating
    case success(latitude: Double, longitude: Double, timestamp: TimeInterval)
    case error(error: Error)
}

struct AppLocation {
    let locationState: LocationState
    let locationRequestState: LocationRequestState
}

enum GeopositionRequestState {
    case none
    case updating
    case success(geoposition: Geoposition)
    case error(error: Error)
}

enum WeatherRequestState {
    case none
    case updating
    case success(currentWeather: Weather, forecast: [Weather])
    case error(error: Error)
}

struct AppWeather {
    let geopositionRequestState: GeopositionRequestState
    let weatherRequestState: WeatherRequestState
}

struct AppState {
    let location: AppLocation
    let weather: AppWeather
}
