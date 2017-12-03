//
//  AppStoreSpec.swift
//  Simple-Weather-AppTests
//
//  Created by Petro Korienev on 11/1/17.
//  Copyright © 2017 Sigma Software. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import Simple_Weather_App

class AppStoreSpec: QuickSpec {
    override func spec() {
        
        // Let's create test model objects to use within states / events
        let weatherJSON: [String: Any] = try! JSONSerialization.jsonObject(with: try! Data.init(contentsOf: Bundle.test.url(forResource: "Weather", withExtension: "json")!)) as! [String: Any]
        let geopositionJSON: [String: Any] = try! JSONSerialization.jsonObject(with: try! Data.init(contentsOf: Bundle.test.url(forResource: "Geoposition", withExtension: "json")!)) as! [String: Any]
        let currentWeatherJSON: [String: Any] = try! JSONSerialization.jsonObject(with: try! Data.init(contentsOf: Bundle.test.url(forResource: "CurrentWeather", withExtension: "json")!)) as! [String: Any]
        
        let weather = try! Weather(JSON: weatherJSON)
        let geoposition = try! Geoposition(JSON: geopositionJSON)
        let currentWeather = try! CurrentWeather(JSON: currentWeatherJSON)
        
        // Let's create more or less comprehensive list of events to test states
        let testEvents: [AppEvent] = [
            .locationPermissionResult(success: false),
            .locationPermissionResult(success: true),
            .locationRequest,
            .locationResult(latitude: nil, longitude: nil, timestamp: nil, error: AppError.inconsistentLocationEvent),
            .locationResult(latitude: 1, longitude: 2, timestamp: Date().timeIntervalSince1970, error: nil),
            .geopositionRequest,
            .geopositionResult(geoposition: nil, error: AppError.inconsistentGeopositionEvent),
            .geopositionResult(geoposition: geoposition, error: nil),
            .weatherRequest,
            .weatherResult(current: nil, forecast: nil, error: AppError.inconsistentWeatherEvent),
            .weatherResult(current: currentWeather, forecast: [weather], error: nil)
        ]
        
        var inputState: AppState!
        var resultStates: [AppState]!
        
        // MARK: Location
        describe("location") {
            // MARK: --Location state
            context("location state") {
                // MARK: ----notYetRequested
                context("notYetRequested state") {
                    // setup initial state and result states
                    let relatedEvents: [Int] = [0, 1]
                    beforeEach {
                        inputState = AppState(location: AppLocation(locationState: .notYetRequested,
                                                                    locationRequestState: .none),
                                              weather: AppWeather(geopositionRequestState: .none,
                                                                  weatherRequestState: .none))
                        resultStates = testEvents.map { appstore_reducer(state: inputState, event: $0) }
                    }
                    it("should change locationState") {
                        // Expected changes
                        expect(resultStates[0].location.locationState) == LocationState.notAvailable
                        expect(resultStates[1].location.locationState) == LocationState.available
                    }
                    it("should not change anything but locationState") {
                        // Expected absence of changes
                        expect(resultStates[0].location.locationRequestState) == inputState.location.locationRequestState
                        expect(resultStates[1].location.locationRequestState) == inputState.location.locationRequestState
                        expect(resultStates[0].weather) == inputState.weather
                        expect(resultStates[1].weather) == inputState.weather
                    }
                    it("should not react on unrelated events") {
                        resultStates.enumerated()
                            .filter { !relatedEvents.contains($0.offset) }
                            .map { $0.element }
                            .forEach { expect($0.location.locationState) == inputState.location.locationState }
                    }
                }
                // MARK: ----notAvailable
                context("notAvailable state") {
                    // setup initial state and result states
                    let relatedEvents: [Int] = [0, 1]
                    beforeEach {
                        inputState = AppState(location: AppLocation(locationState: .notAvailable,
                                                                    locationRequestState: .none),
                                              weather: AppWeather(geopositionRequestState: .none,
                                                                  weatherRequestState: .none))
                        resultStates = testEvents.map { appstore_reducer(state: inputState, event: $0) }
                    }
                    it("should change locationState") {
                        // Expected changes
                        expect(resultStates[0].location.locationState) == LocationState.notAvailable
                        expect(resultStates[1].location.locationState) == LocationState.available
                    }
                    it("should not change anything but locationState") {
                        // Expected absence of changes
                        expect(resultStates[0].location.locationRequestState) == inputState.location.locationRequestState
                        expect(resultStates[1].location.locationRequestState) == inputState.location.locationRequestState
                        expect(resultStates[0].weather) == inputState.weather
                        expect(resultStates[1].weather) == inputState.weather
                    }
                    it("should not react on unrelated events") {
                        resultStates.enumerated()
                            .filter { !relatedEvents.contains($0.offset) }
                            .map { $0.element }
                            .forEach { expect($0.location.locationState) == inputState.location.locationState }
                    }
                }
                // MARK: ----available
                context("available state") {
                    // setup initial state and result states
                    let relatedEvents: [Int] = [0, 1]
                    beforeEach {
                        inputState = AppState(location: AppLocation(locationState: .available,
                                                                    locationRequestState: .none),
                                              weather: AppWeather(geopositionRequestState: .none,
                                                                  weatherRequestState: .none))
                        resultStates = testEvents.map { appstore_reducer(state: inputState, event: $0) }
                    }
                    it("should change locationState") {
                        // Expected changes
                        expect(resultStates[0].location.locationState) == LocationState.notAvailable
                        expect(resultStates[1].location.locationState) == LocationState.available
                    }
                    it("should not change anything but locationState") {
                        // Expected absence of changes
                        expect(resultStates[0].location.locationRequestState) == inputState.location.locationRequestState
                        expect(resultStates[1].location.locationRequestState) == inputState.location.locationRequestState
                        expect(resultStates[0].weather) == inputState.weather
                        expect(resultStates[1].weather) == inputState.weather
                    }
                    it("should not react on unrelated events") {
                        resultStates.enumerated()
                            .filter { !relatedEvents.contains($0.offset) }
                            .map { $0.element }
                            .forEach { expect($0.location.locationState) == inputState.location.locationState }
                    }
                }
            }
            // MARK: --Location request state
            context("location request state") {
                // MARK: ----none
                context("none state") {
                    // setup initial state and result states
                    let relatedEvents: [Int] = [2, 3, 4]
                    beforeEach {
                        inputState = AppState(location: AppLocation(locationState: .available,
                                                                    locationRequestState: .none),
                                              weather: AppWeather(geopositionRequestState: .none,
                                                                  weatherRequestState: .none))
                        resultStates = testEvents.map { appstore_reducer(state: inputState, event: $0) }
                    }
                    it("should change locationRequestState") {
                        // Expected changes
                        expect(resultStates[2].location.locationRequestState) == LocationRequestState.updating
                        expect(resultStates[3].location.locationRequestState.isError).to(beTrue())
                        expect(resultStates[4].location.locationRequestState.isSuccess).to(beTrue())
                    }
                    it("should not change anything but locationRequestState") {
                        // Expected absence of changes
                        expect(resultStates[2].location.locationState) == inputState.location.locationState
                        expect(resultStates[3].location.locationState) == inputState.location.locationState
                        expect(resultStates[4].location.locationState) == inputState.location.locationState
                        expect(resultStates[2].weather) == inputState.weather
                        expect(resultStates[3].weather) == inputState.weather
                        expect(resultStates[4].weather) == inputState.weather
                    }
                    it("should not react on unrelated events") {
                        resultStates.enumerated()
                            .filter { !relatedEvents.contains($0.offset) }
                            .map { $0.element }
                            .forEach { expect($0.location.locationRequestState) == inputState.location.locationRequestState }
                    }
                }
                // MARK: ----updating
                context("updating state") {
                    // setup initial state and result states
                    let relatedEvents: [Int] = [2, 3, 4]
                    beforeEach {
                        inputState = AppState(location: AppLocation(locationState: .available,
                                                                    locationRequestState: .updating),
                                              weather: AppWeather(geopositionRequestState: .none,
                                                                  weatherRequestState: .none))
                        resultStates = testEvents.map { appstore_reducer(state: inputState, event: $0) }
                    }
                    it("should change locationRequestState") {
                        // Expected changes
                        expect(resultStates[2].location.locationRequestState) == LocationRequestState.updating
                        expect(resultStates[3].location.locationRequestState.isError).to(beTrue())
                        expect(resultStates[4].location.locationRequestState.isSuccess).to(beTrue())
                    }
                    it("should not change anything but locationRequestState") {
                        // Expected absence of changes
                        expect(resultStates[2].location.locationState) == inputState.location.locationState
                        expect(resultStates[3].location.locationState) == inputState.location.locationState
                        expect(resultStates[4].location.locationState) == inputState.location.locationState
                        expect(resultStates[2].weather) == inputState.weather
                        expect(resultStates[3].weather) == inputState.weather
                        expect(resultStates[4].weather) == inputState.weather
                    }
                    it("should not react on unrelated events") {
                        resultStates.enumerated()
                            .filter { !relatedEvents.contains($0.offset) }
                            .map { $0.element }
                            .forEach { expect($0.location.locationRequestState) == inputState.location.locationRequestState }
                    }
                }
                // MARK: ----success not older 10 seconds
                context("sucesss state, but not older than 10 seconds") {
                    // setup initial state and result states
                    let relatedEvents: [Int] = [2, 3, 4]
                    beforeEach {
                        inputState = AppState(location: AppLocation(locationState: .available,
                                                                    locationRequestState: .success(latitude: 1, longitude: 2, timestamp: Date().timeIntervalSince1970)),
                                              weather: AppWeather(geopositionRequestState: .none,
                                                                  weatherRequestState: .none))
                        resultStates = testEvents.map { appstore_reducer(state: inputState, event: $0) }
                    }
                    it("should change locationRequestState") {
                        // Expected changes
                        expect(resultStates[2].location.locationRequestState.isSuccess).to(beTrue())
                        expect(resultStates[3].location.locationRequestState.isError).to(beTrue())
                        expect(resultStates[4].location.locationRequestState.isSuccess).to(beTrue())
                    }
                    it("should not change anything but locationRequestState") {
                        // Expected absence of changes
                        expect(resultStates[2].location.locationState) == inputState.location.locationState
                        expect(resultStates[3].location.locationState) == inputState.location.locationState
                        expect(resultStates[4].location.locationState) == inputState.location.locationState
                        expect(resultStates[2].weather) == inputState.weather
                        expect(resultStates[3].weather) == inputState.weather
                        expect(resultStates[4].weather) == inputState.weather
                    }
                    it("should not react on unrelated events") {
                        resultStates.enumerated()
                            .filter { !relatedEvents.contains($0.offset) }
                            .map { $0.element }
                            .forEach { expect($0.location.locationRequestState) == inputState.location.locationRequestState }
                    }
                }
                // MARK: ----success older 10 seconds
                context("sucesss state, older than 10 seconds") {
                    // setup initial state and result states
                    let relatedEvents: [Int] = [2, 3, 4]
                    beforeEach {
                        inputState = AppState(location: AppLocation(locationState: .available,
                                                                    locationRequestState: .success(latitude: 1, longitude: 2, timestamp: Date().timeIntervalSince1970 - 20)),
                                              weather: AppWeather(geopositionRequestState: .none,
                                                                  weatherRequestState: .none))
                        resultStates = testEvents.map { appstore_reducer(state: inputState, event: $0) }
                    }
                    it("should change locationRequestState") {
                        // Expected changes
                        expect(resultStates[2].location.locationRequestState) == LocationRequestState.updating
                        expect(resultStates[3].location.locationRequestState.isError).to(beTrue())
                        expect(resultStates[4].location.locationRequestState.isSuccess).to(beTrue())
                    }
                    it("should not change anything but locationRequestState") {
                        // Expected absence of changes
                        expect(resultStates[2].location.locationState) == inputState.location.locationState
                        expect(resultStates[3].location.locationState) == inputState.location.locationState
                        expect(resultStates[4].location.locationState) == inputState.location.locationState
                        expect(resultStates[2].weather) == inputState.weather
                        expect(resultStates[3].weather) == inputState.weather
                        expect(resultStates[4].weather) == inputState.weather
                    }
                    it("should not react on unrelated events") {
                        resultStates.enumerated()
                            .filter { !relatedEvents.contains($0.offset) }
                            .map { $0.element }
                            .forEach { expect($0.location.locationRequestState) == inputState.location.locationRequestState }
                    }
                }
                // MARK: ----error
                context("error state") {
                    // setup initial state and result states
                    let relatedEvents: [Int] = [2, 3, 4]
                    beforeEach {
                        inputState = AppState(location: AppLocation(locationState: .available,
                                                                    locationRequestState: .error(error: AppError.inconsistentLocationEvent)),
                                              weather: AppWeather(geopositionRequestState: .none,
                                                                  weatherRequestState: .none))
                        resultStates = testEvents.map { appstore_reducer(state: inputState, event: $0) }
                    }
                    it("should change locationRequestState") {
                        // Expected changes
                        expect(resultStates[2].location.locationRequestState) == LocationRequestState.updating
                        expect(resultStates[3].location.locationRequestState.isError).to(beTrue())
                        expect(resultStates[4].location.locationRequestState.isSuccess).to(beTrue())
                    }
                    it("should not change anything but locationRequestState") {
                        // Expected absence of changes
                        expect(resultStates[2].location.locationState) == inputState.location.locationState
                        expect(resultStates[3].location.locationState) == inputState.location.locationState
                        expect(resultStates[4].location.locationState) == inputState.location.locationState
                        expect(resultStates[2].weather) == inputState.weather
                        expect(resultStates[3].weather) == inputState.weather
                        expect(resultStates[4].weather) == inputState.weather
                    }
                    it("should not react on unrelated events") {
                        resultStates.enumerated()
                            .filter { !relatedEvents.contains($0.offset) }
                            .map { $0.element }
                            .forEach { expect($0.location.locationRequestState) == inputState.location.locationRequestState }
                    }
                }
            }
        }
        // MARK: Weather
        describe("weather") {
            // MARK: --GeopositionRequestState
            context("geoposition") {
                // MARK: ----none
                context("none state") {
                    // setup initial state and result states
                    let relatedEvents: [Int] = [5, 6, 7]
                    beforeEach {
                        inputState = AppState(location: AppLocation(locationState: .available,
                                                                    locationRequestState: .success(latitude: 1, longitude: 2, timestamp: Date().timeIntervalSince1970)),
                                              weather: AppWeather(geopositionRequestState: .none,
                                                                  weatherRequestState: .none))
                        resultStates = testEvents.map { appstore_reducer(state: inputState, event: $0) }
                    }
                    it("should change geopositionRequestState") {
                        // Expected changes
                        expect(resultStates[5].weather.geopositionRequestState) == GeopositionRequestState.updating
                        expect(resultStates[6].weather.geopositionRequestState.isError).to(beTrue())
                        expect(resultStates[7].weather.geopositionRequestState.isSuccess).to(beTrue())
                    }
                    it("should not change anything but geopositionRequestState") {
                        // Expected absence of changes
                        expect(resultStates[5].weather.weatherRequestState) == inputState.weather.weatherRequestState
                        expect(resultStates[6].weather.weatherRequestState) == inputState.weather.weatherRequestState
                        expect(resultStates[7].weather.weatherRequestState) == inputState.weather.weatherRequestState
                        expect(resultStates[5].location) == inputState.location
                        expect(resultStates[6].location) == inputState.location
                        expect(resultStates[7].location) == inputState.location
                    }
                    it("should not react on unrelated events") {
                        resultStates.enumerated()
                            .filter { !relatedEvents.contains($0.offset) }
                            .map { $0.element }
                            .forEach { expect($0.weather.geopositionRequestState) == inputState.weather.geopositionRequestState }
                    }
                }
                // MARK: ----updating
                context("updating state") {
                    // setup initial state and result states
                    let relatedEvents: [Int] = [5, 6, 7]
                    beforeEach {
                        inputState = AppState(location: AppLocation(locationState: .available,
                                                                    locationRequestState: .success(latitude: 1, longitude: 2, timestamp: Date().timeIntervalSince1970)),
                                              weather: AppWeather(geopositionRequestState: .updating,
                                                                  weatherRequestState: .none))
                        resultStates = testEvents.map { appstore_reducer(state: inputState, event: $0) }
                    }
                    it("should change geopositionRequestState") {
                        // Expected changes
                        expect(resultStates[5].weather.geopositionRequestState) == GeopositionRequestState.updating
                        expect(resultStates[6].weather.geopositionRequestState.isError).to(beTrue())
                        expect(resultStates[7].weather.geopositionRequestState.isSuccess).to(beTrue())
                    }
                    it("should not change anything but geopositionRequestState") {
                        // Expected absence of changes
                        expect(resultStates[5].weather.weatherRequestState) == inputState.weather.weatherRequestState
                        expect(resultStates[6].weather.weatherRequestState) == inputState.weather.weatherRequestState
                        expect(resultStates[7].weather.weatherRequestState) == inputState.weather.weatherRequestState
                        expect(resultStates[5].location) == inputState.location
                        expect(resultStates[6].location) == inputState.location
                        expect(resultStates[7].location) == inputState.location
                    }
                    it("should not react on unrelated events") {
                        resultStates.enumerated()
                            .filter { !relatedEvents.contains($0.offset) }
                            .map { $0.element }
                            .forEach { expect($0.weather.geopositionRequestState) == inputState.weather.geopositionRequestState }
                    }
                }
                // MARK: ----success
                context("success state") {
                    // setup initial state and result states
                    let relatedEvents: [Int] = [5, 6, 7]
                    beforeEach {
                        inputState = AppState(location: AppLocation(locationState: .available,
                                                                    locationRequestState: .success(latitude: 1, longitude: 2, timestamp: Date().timeIntervalSince1970)),
                                              weather: AppWeather(geopositionRequestState: .success(geoposition: geoposition),
                                                                  weatherRequestState: .none))
                        resultStates = testEvents.map { appstore_reducer(state: inputState, event: $0) }
                    }
                    it("should change geopositionRequestState") {
                        // Expected changes
                        expect(resultStates[5].weather.geopositionRequestState) == GeopositionRequestState.updating
                        expect(resultStates[6].weather.geopositionRequestState.isError).to(beTrue())
                        expect(resultStates[7].weather.geopositionRequestState.isSuccess).to(beTrue())
                    }
                    it("should not change anything but geopositionRequestState") {
                        // Expected absence of changes
                        expect(resultStates[5].weather.weatherRequestState) == inputState.weather.weatherRequestState
                        expect(resultStates[6].weather.weatherRequestState) == inputState.weather.weatherRequestState
                        expect(resultStates[7].weather.weatherRequestState) == inputState.weather.weatherRequestState
                        expect(resultStates[5].location) == inputState.location
                        expect(resultStates[6].location) == inputState.location
                        expect(resultStates[7].location) == inputState.location
                    }
                    it("should not react on unrelated events") {
                        resultStates.enumerated()
                            .filter { !relatedEvents.contains($0.offset) }
                            .map { $0.element }
                            .forEach { expect($0.weather.geopositionRequestState) == inputState.weather.geopositionRequestState }
                    }
                }
                // MARK: ----error
                context("error state") {
                    // setup initial state and result states
                    let relatedEvents: [Int] = [5, 6, 7]
                    beforeEach {
                        inputState = AppState(location: AppLocation(locationState: .available,
                                                                    locationRequestState: .success(latitude: 1, longitude: 2, timestamp: Date().timeIntervalSince1970)),
                                              weather: AppWeather(geopositionRequestState: .error(error: AppError.inconsistentGeopositionEvent),
                                                                  weatherRequestState: .none))
                        resultStates = testEvents.map { appstore_reducer(state: inputState, event: $0) }
                    }
                    it("should change geopositionRequestState") {
                        // Expected changes
                        expect(resultStates[5].weather.geopositionRequestState) == GeopositionRequestState.updating
                        expect(resultStates[6].weather.geopositionRequestState.isError).to(beTrue())
                        expect(resultStates[7].weather.geopositionRequestState.isSuccess).to(beTrue())
                    }
                    it("should not change anything but geopositionRequestState") {
                        // Expected absence of changes
                        expect(resultStates[5].weather.weatherRequestState) == inputState.weather.weatherRequestState
                        expect(resultStates[6].weather.weatherRequestState) == inputState.weather.weatherRequestState
                        expect(resultStates[7].weather.weatherRequestState) == inputState.weather.weatherRequestState
                        expect(resultStates[5].location) == inputState.location
                        expect(resultStates[6].location) == inputState.location
                        expect(resultStates[7].location) == inputState.location
                    }
                    it("should not react on unrelated events") {
                        resultStates.enumerated()
                            .filter { !relatedEvents.contains($0.offset) }
                            .map { $0.element }
                            .forEach { expect($0.weather.geopositionRequestState) == inputState.weather.geopositionRequestState }
                    }
                }
            }
            // MARK: --WeatherRequestState
            context("weather") {
                // MARK: ----none
                context("none state") {
                    // setup initial state and result states
                    let relatedEvents: [Int] = [8, 9, 10]
                    beforeEach {
                        inputState = AppState(location: AppLocation(locationState: .available,
                                                                    locationRequestState: .success(latitude: 1, longitude: 2, timestamp: Date().timeIntervalSince1970)),
                                              weather: AppWeather(geopositionRequestState: .success(geoposition: geoposition),
                                                                  weatherRequestState: .none))
                        resultStates = testEvents.map { appstore_reducer(state: inputState, event: $0) }
                    }
                    it("should change weatherRequestState") {
                        // Expected changes
                        expect(resultStates[8].weather.weatherRequestState) == WeatherRequestState.updating
                        expect(resultStates[9].weather.weatherRequestState.isError).to(beTrue())
                        expect(resultStates[10].weather.weatherRequestState.isSuccess).to(beTrue())
                    }
                    it("should not change anything but weatherRequestState") {
                        // Expected absence of changes
                        expect(resultStates[8].weather.geopositionRequestState) == inputState.weather.geopositionRequestState
                        expect(resultStates[9].weather.geopositionRequestState) == inputState.weather.geopositionRequestState
                        expect(resultStates[10].weather.geopositionRequestState) == inputState.weather.geopositionRequestState
                        expect(resultStates[8].location) == inputState.location
                        expect(resultStates[9].location) == inputState.location
                        expect(resultStates[10].location) == inputState.location
                    }
                    it("should not react on unrelated events") {
                        resultStates.enumerated()
                            .filter { !relatedEvents.contains($0.offset) }
                            .map { $0.element }
                            .forEach { expect($0.weather.weatherRequestState) == inputState.weather.weatherRequestState }
                    }
                }
                // MARK: ----updating
                context("updating state") {
                    // setup initial state and result states
                    let relatedEvents: [Int] = [8, 9, 10]
                    beforeEach {
                        inputState = AppState(location: AppLocation(locationState: .available,
                                                                    locationRequestState: .success(latitude: 1, longitude: 2, timestamp: Date().timeIntervalSince1970)),
                                              weather: AppWeather(geopositionRequestState: .success(geoposition: geoposition),
                                                                  weatherRequestState: .updating))
                        resultStates = testEvents.map { appstore_reducer(state: inputState, event: $0) }
                    }
                    it("should change weatherRequestState") {
                        // Expected changes
                        expect(resultStates[8].weather.weatherRequestState) == WeatherRequestState.updating
                        expect(resultStates[9].weather.weatherRequestState.isError).to(beTrue())
                        expect(resultStates[10].weather.weatherRequestState.isSuccess).to(beTrue())
                    }
                    it("should not change anything but weatherRequestState") {
                        // Expected absence of changes
                        expect(resultStates[8].weather.geopositionRequestState) == inputState.weather.geopositionRequestState
                        expect(resultStates[9].weather.geopositionRequestState) == inputState.weather.geopositionRequestState
                        expect(resultStates[10].weather.geopositionRequestState) == inputState.weather.geopositionRequestState
                        expect(resultStates[8].location) == inputState.location
                        expect(resultStates[9].location) == inputState.location
                        expect(resultStates[10].location) == inputState.location
                    }
                    it("should not react on unrelated events") {
                        resultStates.enumerated()
                            .filter { !relatedEvents.contains($0.offset) }
                            .map { $0.element }
                            .forEach { expect($0.weather.weatherRequestState) == inputState.weather.weatherRequestState }
                    }
                }
                // MARK: ----success
                context("success state") {
                    // setup initial state and result states
                    let relatedEvents: [Int] = [8, 9, 10]
                    beforeEach {
                        inputState = AppState(location: AppLocation(locationState: .available,
                                                                    locationRequestState: .success(latitude: 1, longitude: 2, timestamp: Date().timeIntervalSince1970)),
                                              weather: AppWeather(geopositionRequestState: .success(geoposition: geoposition),
                                                                  weatherRequestState: .success(currentWeather: currentWeather, forecast: [weather])))
                        resultStates = testEvents.map { appstore_reducer(state: inputState, event: $0) }
                    }
                    it("should change weatherRequestState") {
                        // Expected changes
                        expect(resultStates[8].weather.weatherRequestState) == WeatherRequestState.updating
                        expect(resultStates[9].weather.weatherRequestState.isError).to(beTrue())
                        expect(resultStates[10].weather.weatherRequestState.isSuccess).to(beTrue())
                    }
                    it("should not change anything but weatherRequestState") {
                        // Expected absence of changes
                        expect(resultStates[8].weather.geopositionRequestState) == inputState.weather.geopositionRequestState
                        expect(resultStates[9].weather.geopositionRequestState) == inputState.weather.geopositionRequestState
                        expect(resultStates[10].weather.geopositionRequestState) == inputState.weather.geopositionRequestState
                        expect(resultStates[8].location) == inputState.location
                        expect(resultStates[9].location) == inputState.location
                        expect(resultStates[10].location) == inputState.location
                    }
                    it("should not react on unrelated events") {
                        resultStates.enumerated()
                            .filter { !relatedEvents.contains($0.offset) }
                            .map { $0.element }
                            .forEach { expect($0.weather.weatherRequestState) == inputState.weather.weatherRequestState }
                    }
                }
                // MARK: ----error
                context("error state") {
                    // setup initial state and result states
                    let relatedEvents: [Int] = [8, 9, 10]
                    beforeEach {
                        inputState = AppState(location: AppLocation(locationState: .available,
                                                                    locationRequestState: .success(latitude: 1, longitude: 2, timestamp: Date().timeIntervalSince1970)),
                                              weather: AppWeather(geopositionRequestState: .success(geoposition: geoposition),
                                                                  weatherRequestState: .error(error: AppError.inconsistentWeatherEvent)))
                        resultStates = testEvents.map { appstore_reducer(state: inputState, event: $0) }
                    }
                    it("should change weatherRequestState") {
                        // Expected changes
                        expect(resultStates[8].weather.weatherRequestState) == WeatherRequestState.updating
                        expect(resultStates[9].weather.weatherRequestState.isError).to(beTrue())
                        expect(resultStates[10].weather.weatherRequestState.isSuccess).to(beTrue())
                    }
                    it("should not change anything but weatherRequestState") {
                        // Expected absence of changes
                        expect(resultStates[8].weather.geopositionRequestState) == inputState.weather.geopositionRequestState
                        expect(resultStates[9].weather.geopositionRequestState) == inputState.weather.geopositionRequestState
                        expect(resultStates[10].weather.geopositionRequestState) == inputState.weather.geopositionRequestState
                        expect(resultStates[8].location) == inputState.location
                        expect(resultStates[9].location) == inputState.location
                        expect(resultStates[10].location) == inputState.location
                    }
                    it("should not react on unrelated events") {
                        resultStates.enumerated()
                            .filter { !relatedEvents.contains($0.offset) }
                            .map { $0.element }
                            .forEach { expect($0.weather.weatherRequestState) == inputState.weather.weatherRequestState }
                    }
                }
            }
        }
    }
}
