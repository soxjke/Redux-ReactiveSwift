//
//  ViewModelSpec.swift
//  Simple-Weather-AppTests
//
//  Created by Petro Korienev on 12/10/17.
//  Copyright © 2017 Sigma Software. All rights reserved.
//

import Foundation
import Quick
import Nimble
import ReactiveSwift
import Result
@testable import Simple_Weather_App

extension CurrentWeather {
    static var stub: CurrentWeather = .init(effectiveDate: Date(),
                                            phrase: "",
                                            icon: 1,
                                            temperature: .init(unit: "C", value: .single(value: 1)),
                                            realFeel: .init(unit: "C", value: .single(value: 1)),
                                            windSpeed: .init(unit: "m/h", value: .single(value: 1)),
                                            windDirection: "SE")
}

extension DayNightWeather {
    static var stub: DayNightWeather = .init(windSpeed: .init(unit: "m/h", value: .single(value: 1)),
                                             windDirection: "SE",
                                             precipitationProbability: 12,
                                             phrase: "",
                                             icon: 1)
}

extension Weather {
    static var stub: Weather = .init(effectiveDate: Date(),
                                     temperature:  .init(unit: "C", value: .single(value: 1)),
                                     realFeel:  .init(unit: "C", value: .single(value: 1)),
                                     day: DayNightWeather.stub,
                                     night: DayNightWeather.stub)
}

extension AppState {
    static var success: AppState =
        AppState(location: AppLocation(locationState: .notYetRequested,
                                       locationRequestState: .none),
                 weather: AppWeather(geopositionRequestState: .none,
                                     weatherRequestState: WeatherRequestState.success(currentWeather: CurrentWeather.stub,
                                                                                      forecast: [Weather.stub, Weather.stub])))
}

class ViewModelSpec: QuickSpec {
    override func spec() {
        describe("controls enabled") {
            var sut: ViewModel!
            it("should not allow UI when app state is not success") {
                sut = ViewModel(appStore: AppStore.shared, uiStore: ViewModel.UIStore())
                sut.isEnabledControl(for: Set<ViewModel.UIEvent>([.turnLeft])).take(first: 1).startWithValues { expect($0) == false }
                sut.isEnabledControl(for: Set<ViewModel.UIEvent>([.turnRight])).take(first: 1).startWithValues { expect($0) == false }
                sut.isEnabledControl(for: Set<ViewModel.UIEvent>([.turnCurrent])).take(first: 1).startWithValues { expect($0) == false }
                sut.isEnabledControl(for: Set<ViewModel.UIEvent>([.turnForecast])).take(first: 1).startWithValues { expect($0) == false }
            }
            context("when app state is success") {
                let appStore = AppStore(state: AppState.success, reducers: [])
                it("should disable left and right when state is current") {
                    let uiStore = ViewModel.UIStore(state: ViewModel.UIState.current, reducers: [])
                    sut = ViewModel(appStore: appStore, uiStore: uiStore)
                    sut.isEnabledControl(for: Set<ViewModel.UIEvent>([.turnLeft])).take(first: 1).startWithValues { expect($0) == false }
                    sut.isEnabledControl(for: Set<ViewModel.UIEvent>([.turnRight])).take(first: 1).startWithValues { expect($0) == false }
                    sut.isEnabledControl(for: Set<ViewModel.UIEvent>([.turnCurrent])).take(first: 1).startWithValues { expect($0) == true }
                    sut.isEnabledControl(for: Set<ViewModel.UIEvent>([.turnForecast])).take(first: 1).startWithValues { expect($0) == true }
                }
                it("should disable left when state is forecast and selected view is at index 0") {
                    let uiStore = ViewModel.UIStore(state: ViewModel.UIState.forecast(page: 0), reducers: [])
                    sut = ViewModel(appStore: appStore, uiStore: uiStore)
                    sut.isEnabledControl(for: Set<ViewModel.UIEvent>([.turnLeft])).take(first: 1).startWithValues { expect($0) == false }
                    sut.isEnabledControl(for: Set<ViewModel.UIEvent>([.turnRight])).take(first: 1).startWithValues { expect($0) == true }
                    sut.isEnabledControl(for: Set<ViewModel.UIEvent>([.turnCurrent])).take(first: 1).startWithValues { expect($0) == true }
                    sut.isEnabledControl(for: Set<ViewModel.UIEvent>([.turnForecast])).take(first: 1).startWithValues { expect($0) == true }
                }
                it("should disable right when state is forecast and selected view is at last index") {
                    let uiStore = ViewModel.UIStore(state: ViewModel.UIState.forecast(page: 1), reducers: [])
                    sut = ViewModel(appStore: appStore, uiStore: uiStore)
                    sut.isEnabledControl(for: Set<ViewModel.UIEvent>([.turnLeft])).take(first: 1).startWithValues { expect($0) == true }
                    sut.isEnabledControl(for: Set<ViewModel.UIEvent>([.turnRight])).take(first: 1).startWithValues { expect($0) == false }
                    sut.isEnabledControl(for: Set<ViewModel.UIEvent>([.turnCurrent])).take(first: 1).startWithValues { expect($0) == true }
                    sut.isEnabledControl(for: Set<ViewModel.UIEvent>([.turnForecast])).take(first: 1).startWithValues { expect($0) == true }
                }
                it("should switch left and right availability upon changing state") {
                    let uiStore = ViewModel.UIStore(state: ViewModel.UIState.current,
                                                    reducers: [{ _,_ in return ViewModel.UIState.forecast(page: 0) }] )
                    sut = ViewModel(appStore: appStore, uiStore: uiStore)
                    sut.isEnabledControl(for: Set<ViewModel.UIEvent>([.turnLeft])).take(first: 1).collect().startWithValues { expect($0) == [false] }
                    sut.isEnabledControl(for: Set<ViewModel.UIEvent>([.turnRight])).take(first: 2).collect().take(first: 2).startWithValues { expect($0) == [false, true] }
                }
            }
            afterEach {
                sut = nil
            }
        }
        describe("UIStore") {
            context("when current") {
                let state = ViewModel.UIState.current
                it("should switch forecast") {
                    expect(uistore_reducer(state: state, event: .turnForecast)) == .forecast(page: 0)
                }
                it("should not switch left, right and current") {
                    expect(uistore_reducer(state: state, event: .turnLeft)) == ViewModel.UIState.current
                    expect(uistore_reducer(state: state, event: .turnRight)) == ViewModel.UIState.current
                    expect(uistore_reducer(state: state, event: .turnCurrent)) == ViewModel.UIState.current
                }
            }
            context("when forecast") {
                let state = ViewModel.UIState.forecast(page: 0)
                it("should not switch forecast") {
                    expect(uistore_reducer(state: state, event: .turnForecast)) == .forecast(page: 0)
                }
                it("should switch left") {
                    expect(uistore_reducer(state: state, event: .turnLeft)) == .forecast(page: -1)
                }
                it("should switch right") {
                    expect(uistore_reducer(state: state, event: .turnRight)) == .forecast(page: 1)
                }
                it("should switch current") {
                    expect(uistore_reducer(state: state, event: .turnCurrent)) == ViewModel.UIState.current
                }
            }
        }
        describe("actions") {
            let uiReducerSignal: Signal<ViewModel.UIEvent, NoError>
            let uiReducerObserver: Signal<ViewModel.UIEvent, NoError>.Observer
            (uiReducerSignal, uiReducerObserver) = Signal<ViewModel.UIEvent, NoError>.pipe()
            let appReducerSignal: Signal<AppEvent, NoError>
            let appReducerObserver: Signal<AppEvent, NoError>.Observer
            (appReducerSignal, appReducerObserver) = Signal<AppEvent, NoError>.pipe()
            let uiStore = ViewModel.UIStore(state: .current, reducers: [ { uiReducerObserver.send(value: $1); return $0} ])
            let appStore = AppStore(state: .defaultValue, reducers: [ { appReducerObserver.send(value: $1); return $0} ])
            let sut = ViewModel(appStore: appStore, uiStore: uiStore)
            it("should create uiaction") {
                uiReducerSignal.take(first: 1).observeValues { expect($0) == .turnLeft }
                sut.uiAction.apply(.turnLeft).start()
            }
            it("should create reloadaction") {
                appReducerSignal.take(first: 1).observeValues { expect($0).to(Predicate {
                    if case .weatherRequest = try! $0.evaluate().unsafelyUnwrapped {
                        return PredicateResult.init(bool: true, message: ExpectationMessage.expectedActualValueTo(".weatherRequest"))
                    }
                    return PredicateResult.init(bool: false, message: ExpectationMessage.expectedActualValueTo(".weatherRequest"))
                }) }
                sut.reloadAction.apply().start()
            }
            it("should create locateaction") {
                appReducerSignal.take(first: 1).observeValues { expect($0).to(Predicate {
                    if case .locationRequest = try! $0.evaluate().unsafelyUnwrapped {
                        return PredicateResult.init(bool: true, message: ExpectationMessage.expectedActualValueTo(".locationRequest"))
                    }
                    return PredicateResult.init(bool: false, message: ExpectationMessage.expectedActualValueTo(".locationRequest"))
                }) }
                sut.locateAction.apply().start()
            }
            it("should create button action") {
                uiReducerSignal.take(first: 1).observeValues { expect($0) == .turnRight }
                sut.createButtonAction(for: .turnRight).apply().start()
            }
        }
        describe("producers") {
            let appStore = AppStore(state: AppState.success, reducers: [])
            it("should create forecast page producer") {
                let uiStore = ViewModel.UIStore(state: ViewModel.UIState.current, reducers: [uistore_reducer])
                let sut = ViewModel(appStore: appStore, uiStore: uiStore)
                sut.forecastPage.take(first: 3).collect().startWithValues { expect($0) == [0, 1, 0] }
                uiStore.consume(event: .turnForecast)
                uiStore.consume(event: .turnRight)
                uiStore.consume(event: .turnLeft)
            }
            it("should create current or forecast producer") {
                let uiStore = ViewModel.UIStore(state: ViewModel.UIState.current, reducers: [uistore_reducer])
                let sut = ViewModel(appStore: appStore, uiStore: uiStore)
                sut.currentOrForecast.take(first: 3).collect().startWithValues { expect($0) == [true, false, true] }
                uiStore.consume(event: .turnForecast)
                uiStore.consume(event: .turnCurrent)
            }
            it("should create weather features producer") {
                let uiStore = ViewModel.UIStore()
                let sut = ViewModel(appStore: appStore, uiStore: uiStore)
                sut.weatherFeatures.take(first: 1).startWithValues { expect($0) == ViewModel.toWeatherFeatures(appState: AppState.success) }
            }
            it("should create weather forecast features producer") {
                let uiStore = ViewModel.UIStore()
                let sut = ViewModel(appStore: appStore, uiStore: uiStore)
                sut.forecastFeatures.take(first: 1).startWithValues { expect($0).to(Predicate {
                    let expected = ViewModel.toForecastFeatures(appState: AppState.success)
                    let actual = try! $0.evaluate().unsafelyUnwrapped
                    let result = actual.elementsEqual(expected, by: ==)
                    return PredicateResult(bool: result, message: ExpectationMessage.expectedActualValueTo("\(expected)"))
                }) }
            }
        }
    }
}

extension ViewModel.UIState: Equatable {
    public static func ==(lhs: ViewModel.UIState, rhs: ViewModel.UIState) -> Bool {
        if case .current = lhs {
            if case .current = rhs { return true }
        }
        else if case .forecast(let lpage) = lhs {
            if case .forecast(let rpage) = rhs {
                return lpage == rpage
            }
        }
        return false
    }
}

extension WeatherFeatureCellKind: Equatable {
    public static func ==(lhs: WeatherFeatureCellKind, rhs: WeatherFeatureCellKind) -> Bool {
        switch lhs {
        case .captionOnly(let caption):
            if case .captionOnly(let rcaption) = rhs { return caption == rcaption }
        case .icon(let url, let caption):
            if case .icon(let rurl, let rcaption) = rhs { return url == rurl && caption == rcaption }
        case .nameValue(let name, let value):
            if case .nameValue(let rname, let rvalue) = rhs { return name == rname && value == rvalue }
        }
        return false
    }
}
