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
    @IBOutlet private var loadingBarButtonItem: UIBarButtonItem!
    @IBOutlet private var refreshBarButtonItem: UIBarButtonItem!
    @IBOutlet private var locateBarButtonItem: UIBarButtonItem!
    @IBOutlet private weak var leftBarButtonItem: UIBarButtonItem!
    @IBOutlet private weak var rightBarButtonItem: UIBarButtonItem!
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    private lazy var currentWeatherView: WeatherView = WeatherView.fromNib()
    private lazy var forecastScrollView: PagedScrollView = PagedScrollView()
    private var forecastWeatherViews: [WeatherView] = []
    
    private var viewModel = ViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        setupObserving()
    }
    
    func setupSubviews() {
        containerView.addSubview(currentWeatherView)
        containerView.addSubview(forecastScrollView)
        currentWeatherView.snp.makeConstraints { (make) in make.edges.equalToSuperview() }
        forecastScrollView.snp.makeConstraints { (make) in make.edges.equalToSuperview() }
        
        navigationItem.rightBarButtonItems = nil // Hide created from storyboard
    }
    
    func setupObserving() {
        currentWeatherView.reactive.isHidden <~ viewModel.currentOrForecast.negate()
        forecastScrollView.reactive.isHidden <~ viewModel.currentOrForecast
        
        currentWeatherView.reactive.weatherFeatures <~ viewModel.weatherFeatures
        forecastScrollView.reactivePages <~ viewModel.forecastFeatures.map {
            return $0.map {
                let weatherView = WeatherView.fromNib()
                weatherView.reload(with: $0)
                return weatherView
            }
        }
        forecastScrollView.reactiveSetPage() <~ viewModel.forecastPage.logEvents(identifier: "page")
        
        loadingIndicator.reactive.isAnimating <~ viewModel.isLoading
        
        segmentedControl.reactive.isEnabled <~ viewModel.isEnabledControl(for: Set([.turnCurrent, .turnForecast]))
        
        reactive.title <~ viewModel.title
        reactive.rightBarButtonItem <~ viewModel.isLoading.map { [weak self] (isLoading) -> UIBarButtonItem? in
            return isLoading ? self?.loadingBarButtonItem : self?.refreshBarButtonItem
        }
        
        leftBarButtonItem.reactive.pressed = CocoaAction(viewModel.createButtonAction(for: .turnLeft))
        rightBarButtonItem.reactive.pressed = CocoaAction(viewModel.createButtonAction(for: .turnRight))
        refreshBarButtonItem.reactive.pressed = CocoaAction(viewModel.reloadAction)
        locateBarButtonItem.reactive.pressed = CocoaAction(viewModel.locateAction)
        
        let action = viewModel.uiAction
        segmentedControl.reactive.controlEvents(.valueChanged)
            .map { $0.selectedSegmentIndex == 0 ? UIEvent.turnCurrent : UIEvent.turnForecast }
            .observeValues { action.apply($0).start() }
        forecastScrollView.reactivePageProducer()
            .combinePrevious(0)
            .map { $0.1 - $0.0 } // get, -1, 0, 1 values
            .filter { $0 != 0 }
            .filter { [weak self] _ in return !(self?.forecastScrollView.isSoftwareAnimation ?? false) }
            .map { return $0 == 1 ? UIEvent.turnRight : UIEvent.turnLeft }
            .startWithValues { action.apply($0).start() }
        
        //        I would write in more FRP-like way, however Swift is so dumb when it comes to parsing
        //        complex expressions, so let's keep above variant. Maybe one day it will be able to compile
        //        below one.
        //
        //        segmentedControl.reactive.controlEvents(.valueChanged)
        //            .map { $0.selectedSegmentIndex == 0 ? UIEvent.turnCurrent : UIEvent.turnForecast }
        //            .flatMap(.latest) { action.apply($0) }
        //            .observeValues {}
        //        forecastScrollView.reactivePageProducer()
        //            .combinePrevious(0)
        //            .map { $0.0 - $0.1 } // get, -1, 0, 1 values
        //            .filter { $0 != 0 }
        //            .map { return $0 == 1 ? UIEvent.turnRight : UIEvent.turnLeft }
        //            .flatMap(.latest) { action.apply($0) }
        //            .observeValues {}
    }
}

extension Reactive where Base: UIViewController {
    var title: BindingTarget<String?> {
        return makeBindingTarget { $0.title = $1 }
    }
    var rightBarButtonItem: BindingTarget<UIBarButtonItem?> {
        return makeBindingTarget { $0.navigationItem.rightBarButtonItem = $1 }
    }
}
