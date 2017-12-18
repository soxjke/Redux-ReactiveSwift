//
//  ViewModel.swift
//  NutriCalc
//
//  Created by Petro Korienev on 12/15/17.
//  Copyright © 2017 Sigma Software. All rights reserved.
//

import Foundation
import Result
import ReactiveSwift

class ViewModel {

    private let appStore: AppStore
    
    private (set) lazy var uiAction: Action<AppEvent, (), NoError> = createUIAction()
    
    private (set) lazy var weightProducer: SignalProducer<String, NoError> = createWeightProducer()
    private (set) lazy var heightProducer: SignalProducer<String, NoError> = createHeightProducer()
    private (set) lazy var ageProducer: SignalProducer<String, NoError> = createAgeProducer()
    private (set) lazy var kcalProducer: SignalProducer<String, NoError> = createKcalProducer()
    private (set) lazy var errorProducer: SignalProducer<String?, NoError> = createErrorProducer()

    required init(appStore: AppStore) {
        self.appStore = appStore
    }
}

fileprivate extension ViewModel {
    func createUIAction() -> Action<AppEvent, (), NoError> {
        return Action { (event) in
            return SignalProducer { [weak self] in
                self?.appStore.consume(event: event)
            }
        }
    }
    
    // TODO: 3. implement producers
    func createWeightProducer() -> SignalProducer<String, NoError> {
        return appStore.producer.map { "\($0.weight)" }
    }
    
    func createHeightProducer() -> SignalProducer<String, NoError> {
        return appStore.producer.map { "\($0.height)" }
    }
    
    func createAgeProducer() -> SignalProducer<String, NoError> {
        return appStore.producer.map { "\($0.age)" }
    }
    
    func createKcalProducer() -> SignalProducer<String, NoError> {
        return appStore.producer.map { "\($0.dailyCaloriesIntake)" }
    }
    
    func createErrorProducer() -> SignalProducer<String?, NoError> {
        return appStore.producer.map { $0.error }
    }
}

