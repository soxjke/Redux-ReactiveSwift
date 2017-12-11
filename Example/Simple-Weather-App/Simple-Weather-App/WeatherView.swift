//
//  WeatherView.swift
//  Simple-Weather-App
//
//  Created by Petro Korienev on 10/24/17.
//  Copyright © 2017 Sigma Software. All rights reserved.
//

import UIKit
import ReactiveCocoa
import ReactiveSwift
import Result

class WeatherView: UIView {
    private struct Const {
        static let cellIdentifier = "WeatherFeatureCell"
        static let cellHeight: CGFloat = 44
    }
    @IBOutlet private weak var tableView: UITableView!
    fileprivate var weatherFeatures: [WeatherFeatureCellKind] = []
    
    static func fromNib() -> WeatherView {
        guard let view = Bundle.main.loadNibNamed("WeatherView", owner: nil)?.first as? WeatherView else {
            fatalError("No bunlde for: \(String(describing: self))")
        }
        return view
    }
    
    func reload(with weatherFeatures: [WeatherFeatureCellKind]) {
        self.weatherFeatures = weatherFeatures
        tableView.reloadData()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tableView.register(UINib.init(nibName: Const.cellIdentifier, bundle: nil), forCellReuseIdentifier: Const.cellIdentifier)
    }
}

extension WeatherView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return weatherFeatures[indexPath.row].needsStaticHeight() ? Const.cellHeight : UITableViewAutomaticDimension
    }
}

extension WeatherView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherFeatures.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Const.cellIdentifier, for: indexPath) as? WeatherFeatureCell else {
            fatalError("Wrong type of table view cell")
        }
        cell.set(feature: weatherFeatures[indexPath.row])
        return cell
    }
}

extension Reactive where Base == WeatherView {
    var weatherFeatures: BindingTarget<[WeatherFeatureCellKind]> {
        return makeBindingTarget { $0.reload(with: $1) }
    }
}
