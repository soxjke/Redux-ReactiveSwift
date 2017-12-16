//
//  WeatherService.swift
//  Simple-Weather-App
//
//  Created by Petro Korienev on 10/30/17.
//  Copyright © 2017 Sigma Software. All rights reserved.
//

import Foundation
import Alamofire
import ReactiveSwift
import ObjectMapper

class WeatherService {
    private struct Constants {
        static let apiKey = "7yLb1UKneALEl7pON1ryH4qAtkCz1eGG"
    }
    static let shared: WeatherService = WeatherService()
    fileprivate lazy var sessionManager: SessionManager = self.setupSessionManager()
    fileprivate let appStore: AppStore = AppStore.shared
    
    private init() {
        setupObserving()
    }
    
    private func setupObserving() {
        let locationProducer = self.appStore.producer
            .map { $0.location.locationRequestState }
            .filter { $0.isSuccess }
            .skipRepeats()
            .observe(on: QueueScheduler.main)
        locationProducer.startWithValues { [weak self] _ in self?.appStore.consume(event: .geopositionRequest )}
        let geopositionProducer = self.appStore.producer
            .map { $0.weather.geopositionRequestState }
            .skipRepeats()  // To use skipRepeats we have to implement equatable for GeopositionRequestState
            .observe(on: QueueScheduler.main)
        geopositionProducer
            .filter { $0 == .updating }
            .startWithValues { [weak self] _ in self?.performGeopositionRequest() }
        geopositionProducer
            .filter { $0.isSuccess }
            .startWithValues { [weak self] _ in self?.appStore.consume(event: .weatherRequest )}
        let weatherProducer = self.appStore.producer
            .map { $0.weather.weatherRequestState }
            .skipRepeats()  // To use skipRepeats we have to implement equatable for WeatherRequestState
            .filter { $0 == .updating }
            .observe(on: QueueScheduler.main)
        weatherProducer.startWithValues { [weak self] _ in self?.performWeatherRequest() }
    }
    
    private func setupSessionManager() -> SessionManager {
        return SessionManager.default // let's use very default for simplicity
    }
}

extension WeatherService {
    fileprivate func performGeopositionRequest() {
        guard case .success(let latitude, let longitude, _) = self.appStore.value.location.locationRequestState else {
            // There should be assertion thrown here, but for safety let's error the request
            self.appStore.consume(event: .geopositionResult(geoposition: nil, error: AppError.inconsistentStateGeoposition))
            return
        }
        sessionManager
            .request(
                "https://dataservice.accuweather.com/locations/v1/cities/geoposition/search",
                method: .get,
                parameters: ["q": "\(latitude),\(longitude)", "apikey": Constants.apiKey])
            .responseJSON { [weak self] (dataResponse) in
                switch (dataResponse.result) {
                case .failure(let error): self?.appStore.consume(event: .geopositionResult(geoposition: nil, error: error))
                case .success(let value):
                    guard let json = value as? [String: Any] else {
                        self?.appStore.consume(event: .geopositionResult(geoposition: nil, error: AppError.inconsistentAlamofireBehaviour))
                        return
                    }
                    do {
                        let geoposition = try Geoposition(JSON: json)
                        self?.appStore.consume(event: .geopositionResult(geoposition: geoposition, error: nil))
                    } catch (let error) {
                        self?.appStore.consume(event: .geopositionResult(geoposition: nil, error: error))
                    }
                }
        }
    }
    
    fileprivate func performWeatherRequest() {
        guard case .success(let geoposition) = self.appStore.value.weather.geopositionRequestState else {
            // There should be assertion thrown here, but for safety let's error the request
            self.appStore.consume(event: .weatherResult(current: nil, forecast: nil, error: AppError.inconsistentStateWeather))
            return
        }
        performCurrentConditionsRequest(for: geoposition.key)
    }
    
    private func performCurrentConditionsRequest(for key: String) {
        sessionManager
            .request(
                "https://dataservice.accuweather.com/currentconditions/v1/\(key)",
                method: .get,
                parameters: ["details": "true", "apikey": Constants.apiKey])
            .responseJSON { [weak self] (dataResponse) in
                switch (dataResponse.result) {
                case .failure(let error): self?.appStore.consume(event: .weatherResult(current: nil, forecast: nil, error: error))
                case .success(let value):
                    guard let responseJson = value as? [[String: Any]],
                        let weatherJson = responseJson.first else {
                        self?.appStore.consume(event: .weatherResult(current: nil, forecast:nil, error: AppError.inconsistentAlamofireBehaviour))
                        return
                    }
                    do {
                        let weather = try CurrentWeather(JSON: weatherJson)
                        self?.performForecastRequest(for: key, currentConditions: weather)
                    } catch (let error) {
                        self?.appStore.consume(event: .weatherResult(current: nil, forecast: nil, error: error))
                    }
                }
        }
    }
    
    private func performForecastRequest(for key: String, currentConditions: CurrentWeather) {
        sessionManager
            .request(
                "https://dataservice.accuweather.com/forecasts/v1/daily/5day/\(key)",
                method: .get,
                parameters: ["details": "true", "apikey": Constants.apiKey])
            .responseJSON { [weak self] (dataResponse) in
                switch (dataResponse.result) {
                case .failure(let error): self?.appStore.consume(event: .weatherResult(current: nil, forecast: nil, error: error))
                case .success(let value):
                    guard let rootJson = value as? [String: Any],
                    let forecastsJson = rootJson["DailyForecasts"] as? [[String:Any]] else {
                        self?.appStore.consume(event: .weatherResult(current: nil, forecast:nil, error: AppError.inconsistentAlamofireBehaviour))
                        return
                    }
                    do {
                        let forecasts = try Mapper<Weather>().mapArray(JSONArray: forecastsJson)
                        self?.appStore.consume(event: .weatherResult(current: currentConditions,
                                                                     forecast: forecasts,
                                                                     error: nil))
                    } catch (let error) {
                        self?.appStore.consume(event: .weatherResult(current: nil, forecast: nil, error: error))
                    }
                }
        }
    }
}
