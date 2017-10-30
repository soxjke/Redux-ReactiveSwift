//
//  AppState+Extensions.swift
//  Simple-Weather-App
//
//  Created by Petro Korienev on 10/30/17.
//  Copyright © 2017 Sigma Software. All rights reserved.
//

import Foundation

extension LocationRequestState: Equatable {
    public static func ==(lhs: LocationRequestState, rhs: LocationRequestState) -> Bool {
        if case .none = lhs, case .none = rhs { return true }
        if case .updating = lhs, case .updating = rhs { return true }
        if case .success(let latitude, let longitude, let timestamp) = lhs,
            case .success(let latitude1, let longitude1, let timestamp1) = rhs {
            return latitude == latitude1 && longitude == longitude1 && timestamp == timestamp1
        }
        if case .error(let error) = lhs, case .error(let error1) = rhs {
            return error._domain == error1._domain && error._code == error1._code
        }
        return false
    }
}

extension LocationRequestState {
    var isSuccess: Bool {
        guard case .success(_, _, _) = self else { return false }
        return true
    }
    var isError: Bool {
        guard case .error(_) = self else { return false }
        return true
    }
}

extension GeopositionRequestState: Equatable {
    public static func == (lhs: GeopositionRequestState, rhs: GeopositionRequestState) -> Bool {
        if case .none = lhs, case .none = rhs { return true }
        if case .updating = lhs, case .updating = rhs { return true }
        if case .success(let geoposition) = lhs,
            case .success(let geoposition1) = rhs {
            return geoposition == geoposition1
        }
        if case .error(let error) = lhs, case .error(let error1) = rhs {
            return error._domain == error1._domain && error._code == error1._code
        }
        return false
    }
}

extension GeopositionRequestState {
    var isSuccess: Bool {
        guard case .success(_) = self else { return false }
        return true
    }
    var isError: Bool {
        guard case .error(_) = self else { return false }
        return true
    }
}

extension Geoposition: Equatable {
    public static func == (lhs: Geoposition, rhs: Geoposition) -> Bool {
        return lhs.country == rhs.country &&
            lhs.englishName == rhs.englishName &&
            rhs.englishRegion == lhs.englishRegion &&
            rhs.key == lhs.key &&
            rhs.localizedName == lhs.localizedName &&
            rhs.localizedRegion == lhs.localizedRegion
    }
}

extension WeatherRequestState: Equatable {
    public static func == (lhs: WeatherRequestState, rhs: WeatherRequestState) -> Bool {
        if case .none = lhs, case .none = rhs { return true }
        if case .updating = lhs, case .updating = rhs { return true }
        if case .success(_, _) = lhs,
            case .success(_, _) = rhs {
            return true // we explicitly ignore values here, since no reason to compare Weather models
        }
        if case .error(let error) = lhs, case .error(let error1) = rhs {
            return error._domain == error1._domain && error._code == error1._code
        }
        return false
    }
}

enum AppError: String, Error {
    case inconsistentStateGeoposition = "Inconsistent state for location search request"
    case inconsistentStateWeather = "Inconsistent state for weather request"
    case inconsistentLocationEvent = "Inconsistent state for location result"
    case inconsistentGeopositionEvent = "Inconsistent state for AccuWeather location search result"
    case inconsistentWeatherEvent = "Inconsistent state for AccuWeather weather result"
    case inconsistentAlamofireBehaviour = "Alamofire returned incorrect parsing result"
}
