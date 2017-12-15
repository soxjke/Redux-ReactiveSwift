//
//  Geoposition.swift
//  Simple-Weather-App
//
//  Created by Petro Korienev on 10/28/17.
//  Copyright © 2017 Sigma Software. All rights reserved.
//

import Foundation
import ObjectMapper

struct Geoposition {
    let localizedName: String
    let englishName: String
    let localizedRegion: String
    let englishRegion: String
    let country: String
    let key: String
}

extension Geoposition: ImmutableMappable {
    init(map: Map) throws {
        localizedName = try map.value("LocalizedName")
        englishName = try map.value("EnglishName")
        localizedRegion = try map.value("AdministrativeArea.LocalizedName")
        englishRegion = try map.value("AdministrativeArea.EnglishName")
        country = try map.value("Country.ID", using: CountryFlagTransform()) // Let's do a neat flag display
        key = try map.value("Key")
    }
    func mapping(map: Map) {}
    
    // Shamelessly borrowed an idea & partially code from https://stackoverflow.com/a/30403199/2392973
    class CountryFlagTransform: TransformType {
        static let base : UInt32 = 127397
        func transformFromJSON(_ value: Any?) -> String? {
            guard let nonNilValue = value as? String else { return nil }
            return Locale.isoRegionCodes.contains(nonNilValue.uppercased()) ? flag(country: nonNilValue) : nil
        }
        func transformToJSON(_ value: String?) -> String? {
            guard let nonNilValue = value else { return nil }
            guard let country = country(flag: nonNilValue), Locale.isoRegionCodes.contains(country) else { return nil }
            return country
        }
        private func flag(country:String) -> String? {
            var s = ""
            for v in country.uppercased().unicodeScalars {
                guard let scalar = UnicodeScalar(CountryFlagTransform.base + v.value) else { return nil }
                s.unicodeScalars.append(scalar)
            }
            return String(s)
        }
        private func country(flag: String) -> String? {
            var s = ""
            for v in flag.unicodeScalars {
                guard let scalar = UnicodeScalar(v.value - CountryFlagTransform.base) else { return nil }
                s.unicodeScalars.append(scalar)
            }
            return String(s)
        }
    }
}
