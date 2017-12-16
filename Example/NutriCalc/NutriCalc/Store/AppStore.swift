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
    let newWeight = weightReducer(state: state, event: event)
    let newHeight = heightReducer(state: state, event: event)
    let newAge = ageReducer(state: state, event: event)
    let newSex = sexReducer(state: state, event: event)
    let newActivity = activityReducer(state: state, event: event)
    return AppState(weight: newWeight,
                    height: newHeight,
                    age: newAge,
                    maleOrFemale: newSex,
                    activityType: newActivity
    )
}

private func weightReducer(state: AppState, event: AppEvent) -> Int {
    switch(event) {
    case .minusWeight:
        return state.weight - 1
    case .plusWeight:
        return state.weight + 1
    case .setWeight(let weight):
        return weight
    default:
        return state.weight
    }
}

private func heightReducer(state: AppState, event: AppEvent) -> Int {
    switch(event) {
    case .minusHeight:
        return state.height - 1
    case .plusHeight:
        return state.height + 1
    case .setHeight(let height):
        return height
    default:
        return state.height
    }
}

private func ageReducer(state: AppState, event: AppEvent) -> Int {
    switch(event) {
    case .minusAge:
        return state.age - 1
    case .plusAge:
        return state.age + 1
    case .setAge(let age):
        return age
    default:
        return state.age
    }
}

private func sexReducer(state: AppState, event: AppEvent) -> Bool {
    switch(event) {
    case .setMaleOrFemale(let maleOrFemale):
        return maleOrFemale
    default:
        return state.maleOrFemale
    }
}

private func activityReducer(state: AppState, event: AppEvent) -> Float {
    switch(event) {
    case .setActivityType(let activityType):
        return activityType
    default:
        return state.activityType
    }
}

