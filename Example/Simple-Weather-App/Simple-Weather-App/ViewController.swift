//
//  ViewController.swift
//  Simple-Weather-App
//
//  Created by Petro Korienev on 10/24/17.
//  Copyright © 2017 Sigma Software. All rights reserved.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var segmentedControl: UISegmentedControl!
    @IBOutlet private weak var leftBarButtonItem: UIBarButtonItem!
    @IBOutlet private weak var rightBarButtonItem: UIBarButtonItem!
    private lazy var currentWeatherView: WeatherView = WeatherView.fromNib()
    override func viewDidLoad() {
        super.viewDidLoad()
        containerView.addSubview(currentWeatherView)
        currentWeatherView.snp.makeConstraints { (make) in make.edges.equalToSuperview() }
    }
}
