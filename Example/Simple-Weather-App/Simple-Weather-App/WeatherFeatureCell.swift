//
//  WeatherFeatureCell.swift
//  Simple-Weather-App
//
//  Created by Petro Korienev on 10/25/17.
//  Copyright © 2017 Sigma Software. All rights reserved.
//

import UIKit

enum WeatherFeatureCellKind {
    case captionOnly(caption: String)
    case nameValue(name: String, value: String)
    case icon(url: String, caption: String)
    
    func needsStaticHeight() -> Bool {
        if case .nameValue(_, _) = self { return true }
        return false
    }
}

class WeatherFeatureCell: UITableViewCell {
    @IBOutlet private weak var captionLabel: UILabel!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var valueLabel: UILabel!
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var iconCaptionLabel: UILabel!
    
    func set(feature: WeatherFeatureCellKind) {
        switch feature {
        case .captionOnly(let caption): set(caption: caption)
        case .nameValue(let name, let value): set(name: name, value: value)
        case .icon(let url, let caption): set(url: url, caption: caption)
        }
    }
    
    private func set(caption: String) {
        captionLabel.isHidden = false
        captionLabel.text = caption
    }
    
    private func set(name: String, value: String) {
        nameLabel.isHidden = false
        valueLabel.isHidden = false
        nameLabel.text = name
        valueLabel.text = value
    }
    
    private func set(url: String, caption: String) {
        iconImageView.isHidden = false
        iconCaptionLabel.isHidden = false
        //
        iconCaptionLabel.text = caption
    }
    
    private func hideAll() {
        contentView.subviews.forEach { $0.isHidden = true }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        hideAll()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.image = nil
        hideAll()
    }
}
