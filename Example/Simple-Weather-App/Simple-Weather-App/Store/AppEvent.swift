//
//  AppEvent.swift
//  Simple-Weather-App
//
//  Created by Petro Korienev on 10/30/17.
//  Copyright © 2017 Sigma Software. All rights reserved.
//

import Foundation

enum AppEvent {
    case locationPermissionResult(success: Bool)
    case locationRequest
    case locationResult(latitude: Double?, longitude: Double?, timestamp: TimeInterval?, error: Error?)
    case geopositionRequest
    case geopositionResult(geoposition: Geoposition?, error: Error?)
    case weatherRequest
    case weatherResult(current: CurrentWeather?, forecast: [Weather]?, error: Error?)
}
