//
//  LocationService.swift
//  Simple-Weather-App
//
//  Created by Petro Korienev on 10/30/17.
//  Copyright © 2017 Sigma Software. All rights reserved.
//

import Foundation
import CoreLocation
import ReactiveSwift

class LocationService: NSObject {
    static let shared: LocationService = LocationService()
    fileprivate lazy var locationManager: CLLocationManager = self.setupLocationManager()
    fileprivate let appStore: AppStore = AppStore.shared
    
    private override init() {
        super.init()
        setupObserving()
    }
    
    private func setupObserving() {
        let locationProducer = self.appStore.producer
            .map { $0.location.locationState }
            .skipRepeats()
            .observe(on: QueueScheduler.main)
        locationProducer
            .filter { $0 == .notYetRequested }
            .startWithValues { [weak self] _ in self?.locationManager.requestWhenInUseAuthorization() }
        locationProducer
            .filter { $0 == .available }
            .startWithValues { [weak self] _ in self?.appStore.consume(event: .locationRequest) }
        let locationRequestProducer = self.appStore.producer
            .map { $0.location.locationRequestState }
            .skipRepeats() // To use skipRepeats we have to implement equatable for LocationRequestState
            .observe(on: QueueScheduler.main)
        locationRequestProducer
            .filter { $0 == .updating}
            .startWithValues { [weak self] _ in self?.locationManager.startUpdatingLocation() }
        locationRequestProducer
            .filter { $0 != .updating && $0 != .none } // get only success or error
            .startWithValues { [weak self] _ in self?.locationManager.stopUpdatingLocation() }
    }
    
    private func setupLocationManager() -> CLLocationManager {
        let result = CLLocationManager()
        result.delegate = self
        result.desiredAccuracy = kCLLocationAccuracyKilometer
        return result
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        appStore.consume(event: status.appEvent)
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        appStore.consume(event: .locationResult(latitude: nil, longitude: nil, timestamp: nil, error: error))
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        appStore.consume(event: .locationResult(latitude: location.coordinate.latitude,
                                                longitude: location.coordinate.longitude,
                                                timestamp: location.timestamp.timeIntervalSince1970,
                                                error: nil))
    }
}

private extension CLAuthorizationStatus {
    var appEvent: AppEvent {
        switch self {
        case .notDetermined, .restricted, .denied: return .locationPermissionResult(success: false)
        case .authorizedWhenInUse, .authorizedAlways: return .locationPermissionResult(success: true)
        }
    }
}
