//
//  WeatherView.swift
//  Simple-Weather-App
//
//  Created by Petro Korienev on 10/24/17.
//  Copyright © 2017 Sigma Software. All rights reserved.
//

import UIKit

class WeatherView: UIView {
    private struct Const {
        static let cellIdentifier = "WeatherFeatureCell"
    }
    @IBOutlet private weak var tableView: UITableView!
    
    static func fromNib() -> WeatherView {
        guard let view = Bundle.main.loadNibNamed("WeatherView", owner: nil)?.first as? WeatherView else {
            fatalError("No bunlde for: \(String(describing: self))")
        }
        return view
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tableView.register(UINib.init(nibName: Const.cellIdentifier, bundle: nil), forCellReuseIdentifier: Const.cellIdentifier)
    }
}

extension WeatherView: UITableViewDelegate {}

extension WeatherView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: Const.cellIdentifier, for: indexPath)
    }
}
