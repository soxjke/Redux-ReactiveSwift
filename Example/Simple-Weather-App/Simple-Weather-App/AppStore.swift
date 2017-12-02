//
//  AppStore.swift
//  Simple-Weather-App
//
//  Created by Petro Korienev on 10/30/17.
//  Copyright © 2017 Sigma Software. All rights reserved.
//

import Foundation
import Redux_ReactiveSwift

extension AppState: Defaultable {
    static var defaultValue: AppState = AppState(location: AppLocation(locationState: .notYetRequested,
                                                                       locationRequestState: .none),
                                                 weather: AppWeather(geopositionRequestState: .none,
                                                                     weatherRequestState: .none))
}

final class AppStore: Store<AppState, AppEvent> {
    static let shared: AppStore = AppStore()
    private init() {
        super.init(state: AppState.defaultValue, reducers: [appstore_reducer])
    }
    required init(state: AppState, reducers: [AppStore.Reducer]) {
        fatalError("init(state:reducers:) cannot be called on type AppStore. Use `shared` accessor")
    }
}

internal func appstore_reducer(state: AppState, event: AppEvent) -> AppState {
    return AppState(location: locationReducer(state.location, event),
                    weather: weatherReducer(state.weather, event))
}
// MARK: Location reducers
fileprivate func locationReducer(_ state: AppLocation, _ event: AppEvent) -> AppLocation {
    switch event {
    case .locationPermissionResult(let success): return location(permissionResult: success, previous: state)
    case .locationRequest: return locationRequest(previous: state)
    case .locationResult(let latitude, let longitude, let timestamp, let error):
        return locationResult(latitude: latitude, longitude: longitude, timestamp: timestamp, error: error, previous: state)
    default: return state
    }
}
fileprivate func location(permissionResult: Bool, previous: AppLocation) -> AppLocation {
    return AppLocation(locationState: permissionResult ? .available : .notAvailable,
                       locationRequestState: previous.locationRequestState)
}
fileprivate func locationRequest(previous: AppLocation) -> AppLocation {
    guard case .available = previous.locationState else { return previous }
    if case .success(_, _, let timestamp) = previous.locationRequestState {
        if (Date().timeIntervalSince1970 - timestamp < 300) { // Don't do update if location succeeded within last 5 minutes
            return previous
        }
    }
    return AppLocation(locationState: previous.locationState, locationRequestState: .updating) // Perform location update
}
fileprivate func locationResult(latitude: Double?, longitude: Double?, timestamp: TimeInterval?, error: Swift.Error?, previous: AppLocation) -> AppLocation {
    guard let error = error else {
        if let latitude = latitude, let longitude = longitude, let timestamp = timestamp {
            return AppLocation(locationState: previous.locationState, locationRequestState: .success(latitude: latitude, longitude: longitude, timestamp: timestamp))
        }
        return AppLocation(locationState: previous.locationState, locationRequestState: .error(error: AppError.inconsistentLocationEvent))
    }
    return AppLocation(locationState: previous.locationState, locationRequestState: .error(error: error))
}
// MARK: Weather reducers
fileprivate func weatherReducer(_ state: AppWeather, _ event: AppEvent) -> AppWeather {
    switch event {
    case .geopositionRequest: return geopositionRequest(previous: state)
    case .geopositionResult(let geoposition, let error): return geopositionResult(geoposition: geoposition, error: error, previous: state)
    case .weatherRequest: return weatherRequest(previous: state)
    case .weatherResult(let current, let forecast, let error): return weatherResult(current: current, forecast: forecast, error: error, previous: state)
    default: return state
    }
}
fileprivate func geopositionRequest(previous: AppWeather) -> AppWeather {
    return AppWeather(geopositionRequestState: .updating, weatherRequestState: previous.weatherRequestState)
}
fileprivate func geopositionResult(geoposition: Geoposition?, error: Swift.Error?, previous: AppWeather) -> AppWeather {
    guard let error = error else {
        if let geoposition = geoposition {
            return AppWeather(geopositionRequestState: .success(geoposition: geoposition), weatherRequestState: previous.weatherRequestState)
        }
        return AppWeather(geopositionRequestState: .error(error: AppError.inconsistentGeopositionEvent), weatherRequestState: previous.weatherRequestState)
    }
    return AppWeather(geopositionRequestState: .error(error: error), weatherRequestState: previous.weatherRequestState)
}
fileprivate func weatherRequest(previous: AppWeather) -> AppWeather {
    return AppWeather(geopositionRequestState: previous.geopositionRequestState, weatherRequestState: .updating)
}
fileprivate func weatherResult(current: CurrentWeather?, forecast: [Weather]?, error: Swift.Error?, previous: AppWeather) -> AppWeather {
    guard let error = error else {
        if let current = current, let forecast = forecast {
            return AppWeather(geopositionRequestState: previous.geopositionRequestState,
                              weatherRequestState: .success(currentWeather: current, forecast: forecast))
        }
        return AppWeather(geopositionRequestState: .error(error: AppError.inconsistentWeatherEvent), weatherRequestState: previous.weatherRequestState)
    }
    return AppWeather(geopositionRequestState: previous.geopositionRequestState, weatherRequestState: .error(error: error))
}
