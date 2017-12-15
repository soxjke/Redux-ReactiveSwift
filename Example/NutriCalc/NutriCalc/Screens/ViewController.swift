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
    }
    
    func setupOtherActions() {
        let action = viewModel.uiAction
        weightTextField.reactive.textValues.skipNil().map(Int.init).skipNil().observeValues { action.apply(.setWeight(weight: $0)).start() }
        heightTextField.reactive.textValues.skipNil().map(Int.init).skipNil().observeValues { action.apply(.setWeight(weight: $0)).start() }
        weightTextField.reactive.textValues.skipNil().map(Int.init).skipNil().observeValues { action.apply(.setWeight(weight: $0)).start() }
        // TODO: 4. Setup other bindings
    }
}

