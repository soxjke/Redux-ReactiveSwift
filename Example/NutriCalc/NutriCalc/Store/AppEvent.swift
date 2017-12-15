//
//  AppEvent.swift
//  NutriCalc
//
//  Created by Petro Korienev on 12/15/17.
//  Copyright © 2017 Sigma Software. All rights reserved.
//

import Foundation

enum AppEvent {
    case plusWeight
    case minusWeight
    case setWeight(weight: Int)
    case plusHeight
    case minusHeight
    case setHeight(height: Int)
    case plusAge
    case minusAge
    case setAge(age: Int)
    case setMaleOrFemale(maleOrFemale: Bool)
    case setActivityType(activityType: Float)
}
