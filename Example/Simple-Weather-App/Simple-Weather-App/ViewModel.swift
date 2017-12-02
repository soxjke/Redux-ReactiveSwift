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
    private (set) lazy var weatherFeatures: Property<[WeatherFeatureCellKind]> = .init(capturing: self.mutableWeatherFeatures)
    private let mutableWeatherFeatures: MutableProperty<[WeatherFeatureCellKind]> = .init([])
    
    init() {
        uiStore.producer.logEvents().start()
        setupObserving()
    }
    
    func setupObserving() {
        mutableWeatherFeatures <~ uiStore.producer
            .combineLatest(with: appStore.producer.filter { $0.weather.weatherRequestState.isSuccess } )
            .map(ViewModel.toWeatherFeatures)
    }
    
    private static func toWeatherFeatures(uiState: UIState, appState: AppState) -> [WeatherFeatureCellKind] {
        guard case .success(let currentWeather, let forecast) = appState.weather.weatherRequestState else {
            return []
        }
        switch uiState {
        case .current: return currentWeather.toWeatherFeatures()
        case .forecast(let page): return page < forecast.count ? forecast[page].toWeatherFeatures() : []
        }
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
        return []
    }
}

private extension CurrentWeather {
    func toWeatherFeatures() -> [WeatherFeatureCellKind] {
        return [
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
        case .minmax(let min, let max): return .nameValue(name: name, value: "\(min)..\(max) \(self.unit)")
        }
    }
        
    static func weatherFeatureCellKind(name: String, day: WeatherFeature, night: WeatherFeature) -> WeatherFeatureCellKind {
        var resultString: String = ""
        switch day.value {
        case .single(let value): resultString = resultString + "\(value)"
        case .minmax(let min, let max): resultString = resultString + "\(min)..\(max)"
        }
        switch night.value {
        case .single(let value): resultString = resultString + " / \(value)"
        case .minmax(let min, let max): resultString = resultString + " / \(min)..\(max)"
        }
        return .nameValue(name: name, value: "\(resultString) \(day.unit)")
    }
}
