//
//  ViewModel.swift
//  Simple-Weather-App
//
//  Created by Petro Korienev on 11/11/17.
//  Copyright © 2017 Sigma Software. All rights reserved.
//

import Foundation
import Redux_ReactiveSwift
import Result
import ReactiveSwift

enum UIState {
    case current
    case forecast(page: Int)
}

enum UIEvent {
    case turnCurrent
    case turnForecast
    case turnLeft
    case turnRight
}

class ViewModel {
    class UIStore: Store<UIState, UIEvent> {
        fileprivate init() {
            super.init(state: .current, reducers: [uistore_reducer])
        }
        required init(state: UIState, reducers: [UIStore.Reducer]) {
            fatalError("init(state:reducers:) cannot be called on type UIStore. Use `shared` accessor")
        }
    }
    
    private let uiStore = UIStore()
    private let appStore = AppStore.shared
    
    private (set) lazy var uiAction: Action<UIEvent, (), NoError> = createUIAction()
    private (set) lazy var reloadAction:  Action<(), (), NoError> = createReloadAction()
    private (set) lazy var locateAction:  Action<(), (), NoError> = createLocateAction()

    private (set) lazy var forecastPage: SignalProducer<Int, NoError> = self.forecastPageProducer()
    private (set) lazy var currentOrForecast: SignalProducer<Bool, NoError> = self.currentOrForecastProducer()
    private (set) lazy var weatherFeatures: SignalProducer<[WeatherFeatureCellKind], NoError> = self.weatherFeaturesProducer()
    private (set) lazy var forecastFeatures: SignalProducer<[[WeatherFeatureCellKind]], NoError> = self.forecastFeaturesProducer()
    private (set) lazy var title: SignalProducer<String, NoError> = self.appStore.producer.map(ViewModel.geopositionString).skipRepeats()
    private (set) lazy var isLoading: SignalProducer<Bool, NoError> = self.appStore.producer.map(ViewModel.isLoading).skipRepeats()
    
    func isEnabledControl(for events: Set<UIEvent>) -> SignalProducer<Bool, NoError> {
        return uiStore.producer
            .combineLatest(with: appStore.producer)
            .map { (uiState, appState) -> Bool in
                guard case .success(_, let forecast) = appState.weather.weatherRequestState else {
                    return false
                }
                var allowedEvents = Set<UIEvent>([.turnCurrent, .turnForecast])
                if case .forecast(let page) = uiState {
                    if page > 0 {
                        allowedEvents = allowedEvents.union([.turnLeft])
                    }
                    if page < forecast.count - 1 {
                        allowedEvents = allowedEvents.union([.turnRight])
                    }
                }
                return allowedEvents.isSuperset(of: events)
        }
        .skipRepeats()
    }
}

extension ViewModel {
    fileprivate func createUIAction() -> Action<UIEvent, (), NoError> {
        return Action { (event) in
            return SignalProducer { [weak self] in
                self?.uiStore.consume(event: event)
            }
        }
    }
    func createButtonAction(for event: UIEvent) -> Action<(), (), NoError> {
        return Action(enabledIf: Property(initial: false, then: isEnabledControl(for: Set([event]))) ) {
            return SignalProducer { [weak self] in
                self?.uiStore.consume(event: event)
            }
        }
    }
    fileprivate func createReloadAction() -> Action<(), (), NoError> {
        return Action {
            return SignalProducer { [weak self] in
                self?.appStore.consume(event: .weatherRequest)
            }
        }
    }
    fileprivate func createLocateAction() -> Action<(), (), NoError> {
        let enabledProducer = appStore.producer.map { (appState) in
            return !(appState.location.locationRequestState.isUpdating || appState.weather.geopositionRequestState.isUpdating)
        }
        return Action(enabledIf: Property(initial: false, then: enabledProducer)) {
            return SignalProducer { [weak self] in
                self?.appStore.consume(event: .locationRequest)
            }
        }
    }
    fileprivate func forecastPageProducer() -> SignalProducer<Int, NoError> {
        return uiStore.producer
            .filter { if case .current = $0 { return false } else { return true } }
            .map { if case .forecast(let page) = $0 { return page } else { return 0 } }
    }
    fileprivate func currentOrForecastProducer() -> SignalProducer<Bool, NoError> {
        return uiStore.producer.map { if case .current = $0 { return true } else { return false } }
    }
    fileprivate func weatherFeaturesProducer() -> SignalProducer<[WeatherFeatureCellKind], NoError> {
        return appStore.producer.map(ViewModel.toWeatherFeatures)
    }
    fileprivate func forecastFeaturesProducer() -> SignalProducer<[[WeatherFeatureCellKind]], NoError> {
        return appStore.producer.map(ViewModel.toForecastFeatures)
    }
    
    fileprivate static func toWeatherFeatures(appState: AppState) -> [WeatherFeatureCellKind] {
        guard case .success(let currentWeather, _) = appState.weather.weatherRequestState else {
            return []
        }
        return currentWeather.toWeatherFeatures()
    }
    
    fileprivate static func toForecastFeatures(appState: AppState) -> [[WeatherFeatureCellKind]] {
        guard case .success(_, let forecast) = appState.weather.weatherRequestState else {
            return []
        }
        return forecast.map { $0.toWeatherFeatures() }
    }
    
    fileprivate static func geopositionString(appState: AppState) -> String {
        if case .success(let geoposition) = appState.weather.geopositionRequestState {
            return "\(geoposition.englishName), \(geoposition.englishRegion) \(geoposition.country)"
        }
        return "Locating.."
    }
    
    fileprivate static func isLoading(appState: AppState) -> Bool {
        return appState.weather.weatherRequestState.isUpdating ||
                appState.weather.geopositionRequestState.isUpdating ||
                appState.location.locationRequestState.isUpdating
    }
}

func uistore_reducer(state: UIState, event: UIEvent) -> UIState {
    switch event {
    case .turnCurrent: return .current
    case .turnForecast: return .forecast(page: 0)
    case .turnLeft: if case .forecast(let page) = state { return .forecast(page: page - 1) } else { return state }
    case .turnRight: if case .forecast(let page) = state { return .forecast(page: page + 1) } else { return state }
    }
}

private extension Weather {
    func toWeatherFeatures() -> [WeatherFeatureCellKind] {
        return [
            .nameValue(name: "Date", value: effectiveDate.toString()),
            .icon(url: String(format: "https://developer.accuweather.com/sites/default/files/%02d-s.png", day.icon),
                  caption: "Day: \(day.phrase)"),
            .icon(url: String(format: "https://developer.accuweather.com/sites/default/files/%02d-s.png", night.icon),
                  caption: "Night: \(night.phrase)"),
            .captionOnly(caption: "Forecast"),
            temperature.toWeatherFeatureCellKind(name: "Temperature"),
            realFeel.toWeatherFeatureCellKind(name: "Real feel"),
            .nameValue(name: "Rain", value: "\(day.precipitationProbability)% / \(night.precipitationProbability)%"),
            WeatherFeature.weatherFeatureCellKind(name: "Wind (\(day.windDirection)/\(night.windDirection)) ", day: day.windSpeed, night: night.windSpeed)
        ]
    }
}

private extension CurrentWeather {
    func toWeatherFeatures() -> [WeatherFeatureCellKind] {
        return [
            .nameValue(name: "Date", value: effectiveDate.toString()),
            .icon(url: String(format: "https://developer.accuweather.com/sites/default/files/%02d-s.png", self.icon),
                  caption: self.phrase),
            temperature.toWeatherFeatureCellKind(name: "Temperature"),
            realFeel.toWeatherFeatureCellKind(name: "Real feel"),
            windSpeed.toWeatherFeatureCellKind(name: "Wind (\(windDirection))")
        ]
    }
}

private extension WeatherFeature {
    func toWeatherFeatureCellKind(name: String) -> WeatherFeatureCellKind {
        switch self.value {
        case .single(let value): return .nameValue(name: name, value: "\(value) \(self.unit)")
        case .minmax(let min, let max): return .nameValue(name: name, value: "\(min) ... \(max) \(self.unit)")
        }
    }
    
    static func weatherFeatureCellKind(name: String, day: WeatherFeature, night: WeatherFeature) -> WeatherFeatureCellKind {
        var resultString: String = ""
        switch day.value {
        case .single(let value): resultString = resultString + "\(value)"
        case .minmax(let min, let max): resultString = resultString + "\(min) ... \(max)"
        }
        switch night.value {
        case .single(let value): resultString = resultString + " / \(value)"
        case .minmax(let min, let max): resultString = resultString + " / \(min) ... \(max)"
        }
        return .nameValue(name: name, value: "\(resultString) \(day.unit)")
    }
}

extension Date {
    private struct Constants {
        static let dateFormatter = createDateFormatter()
        static func createDateFormatter() -> DateFormatter {
            let df = DateFormatter(withFormat: "YYYY-MMM-dd, HH:mm", locale: Locale.current.identifier)
            return df
        }
    }
    func toString() -> String {
        return Constants.dateFormatter.string(from: self)
    }
}
