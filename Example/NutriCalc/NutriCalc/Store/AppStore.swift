//
//  AppStore.swift
//  NutriCalc
//
//  Created by Petro Korienev on 12/15/17.
//  Copyright © 2017 Sigma Software. All rights reserved.
//

import Foundation
import Redux_ReactiveSwift

extension AppState: Defaultable {
    static var defaultValue: AppState = .init(weight: 50,
                                              height: 160,
                                              age: 25,
                                              maleOrFemale: false,
                                              activityType: 1.375)
}

final class AppStore: Store<AppState, AppEvent> {
    static let shared: AppStore = AppStore()
    init() {
        super.init(state: AppState.defaultValue, reducers: [appstore_reducer])
    }
    required init(state: AppState, reducers: [AppStore.Reducer]) {
        super.init(state: state, reducers: reducers)
    }
}

internal func appstore_reducer(state: AppState, event: AppEvent) -> AppState {
    // TODO: 1. implement reducer
    return AppState.defaultValue
}

