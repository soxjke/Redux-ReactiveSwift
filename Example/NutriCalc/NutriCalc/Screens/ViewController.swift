//
//  ViewController.swift
//  NutriCalc
//
//  Created by Petro Korienev on 12/15/17.
//  Copyright © 2017 Sigma Software. All rights reserved.
//

import UIKit
import ReactiveCocoa
import ReactiveSwift
import Result
import SnapKit

class ViewController: UIViewController {

    @IBOutlet private var minusWeightButton: UIButton!
    @IBOutlet private var plusWeightButton: UIButton!
    @IBOutlet private var minusHeightButton: UIButton!
    @IBOutlet private var plusHeightButton: UIButton!
    @IBOutlet private var minusAgeButton: UIButton!
    @IBOutlet private var plusAgeButton: UIButton!
    @IBOutlet private var maleOrFemaleSwitch: UISwitch!
    @IBOutlet private var activitySlider: UISlider!
    @IBOutlet private var kilocaloriesLabel: UILabel!
    
    @IBOutlet private var weightTextField: UITextField!
    @IBOutlet private var heightTextField: UITextField!
    @IBOutlet private var ageTextField: UITextField!
    
    @IBOutlet private var error: UILabel!
    
    let viewModel = ViewModel(appStore: AppStore.shared)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "NutriCalc"
        setupBindings()
    }
    
    func setupBindings() {
        setupButtonBindings()
        setupFieldBindings()
        setupOtherActions()
    }
    
    func setupButtonBindings() {
        minusWeightButton.reactive.pressed = CocoaAction(viewModel.uiAction, input: .minusWeight)
        plusWeightButton.reactive.pressed = CocoaAction(viewModel.uiAction, input: .plusWeight)
        minusHeightButton.reactive.pressed = CocoaAction(viewModel.uiAction, input: .minusHeight)
        plusHeightButton.reactive.pressed = CocoaAction(viewModel.uiAction, input: .plusHeight)
        minusAgeButton.reactive.pressed = CocoaAction(viewModel.uiAction, input: .minusAge)
        plusAgeButton.reactive.pressed = CocoaAction(viewModel.uiAction, input: .plusAge)
    }
    
    func setupFieldBindings() {
        weightTextField.reactive.text <~ viewModel.weightProducer
        heightTextField.reactive.text <~ viewModel.heightProducer
        ageTextField.reactive.text <~ viewModel.ageProducer
        kilocaloriesLabel.reactive.text <~ viewModel.kcalProducer
        error.reactive.text <~ viewModel.errorProducer
    }
    
    func setupOtherActions() {
        let action = viewModel.uiAction
        weightTextField.reactive.continuousTextValues.skipNil().map(Int.init).skipNil().observeValues { action.apply(.setWeight(weight: $0)).start() }
        heightTextField.reactive.continuousTextValues.skipNil().map(Int.init).skipNil().observeValues { action.apply(.setHeight(height: $0)).start() }
        ageTextField.reactive.continuousTextValues.skipNil().map(Int.init).skipNil().observeValues { action.apply(.setAge(age: $0)).start() }
        
        maleOrFemaleSwitch.reactive.isOnValues.observeValues { action.apply(.setMaleOrFemale(maleOrFemale: $0)).start() }
        activitySlider.reactive.values.observeValues { action.apply(.setActivityType(activityType: $0)).start() }
    }
}

