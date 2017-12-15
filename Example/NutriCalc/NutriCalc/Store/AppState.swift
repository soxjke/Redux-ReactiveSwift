//
//  AppState.swift
//  NutriCalc
//
//  Created by Petro Korienev on 12/15/17.
//  Copyright © 2017 Sigma Software. All rights reserved.
//

import Foundation

struct AppState {
    var weight: Int
    var height: Int
    var age: Int
    var maleOrFemale: Bool
    var activityType: Float
}

extension AppState {
    var dailyCaloriesIntake: Float {
        // TODO: 2. implement Harris-Benedict equaion
        return 0
    }
}
