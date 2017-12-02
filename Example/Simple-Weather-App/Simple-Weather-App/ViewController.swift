//
//  ViewController.swift
//  Simple-Weather-App
//
//  Created by Petro Korienev on 10/24/17.
//  Copyright © 2017 Sigma Software. All rights reserved.
//

import UIKit
import SnapKit
import ReactiveCocoa
import ReactiveSwift
import Result

class ViewController: UIViewController {
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var segmentedControl: UISegmentedControl!
    @IBOutlet private weak var leftBarButtonItem: UIBarButtonItem!
    @IBOutlet private weak var rightBarButtonItem: UIBarButtonItem!
    private lazy var currentWeatherView: WeatherView = WeatherView.fromNib()
    
    private var viewModel = ViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        setupObserving()
    }
    
    func setupSubviews() {
        containerView.addSubview(currentWeatherView)
        currentWeatherView.snp.makeConstraints { (make) in make.edges.equalToSuperview() }
    }
    
    func setupObserving() {
        let action = viewModel.uiAction
        leftBarButtonItem.reactive.pressed = CocoaAction(action, input: .turnLeft)
        rightBarButtonItem.reactive.pressed = CocoaAction(action, input: .turnRight)
        segmentedControl.reactive.controlEvents(.valueChanged)
            .map { $0.selectedSegmentIndex == 0 ? UIEvent.turnCurrent : UIEvent.turnForecast }
            .observeValues { action.apply($0).start() }
        currentWeatherView.reactive.weatherFeatures <~ viewModel.weatherFeatures
    }
}
