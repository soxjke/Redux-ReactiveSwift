//
//  GeopositionSpec.swift
//  Simple-Weather-AppTests
//
//  Created by Petro Korienev on 10/28/17.
//  Copyright © 2017 Sigma Software. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import Simple_Weather_App

class GeopositionSpec: QuickSpec {
    override func spec() {
        let geopositionJSON: [String: Any] = try! JSONSerialization.jsonObject(with: try! Data.init(contentsOf: Bundle.test.url(forResource: "Geoposition", withExtension: "json")!)) as! [String: Any]
        describe("parsing") {
            let geoposition = try? Geoposition(JSON: geopositionJSON)
            it("should parse geoposition") {
                expect(geoposition).notTo(beNil())
            }
            it("should parse name") {
                expect(geoposition!.localizedName).to(equal("Sao Vicente"))
                expect(geoposition!.englishName).to(equal("Sao Vicente"))
            }
            it("should parse region") {
                expect(geoposition!.localizedRegion).to(equal("Madeira"))
                expect(geoposition!.englishRegion).to(equal("Madeira"))
            }
            it("should parse key") {
                expect(geoposition!.key).to(equal("274357"))
            }
            it("should parse country") {
                expect(geoposition!.country).to(equal("🇵🇹"))
            }
        }
        describe("country flag transform") {
            let transform = Geoposition.CountryFlagTransform()
            it("should correctly transform all known region codes") {
                Locale.isoRegionCodes.forEach {
                    expect(transform.transformToJSON(transform.transformFromJSON($0))).to(equal($0))
                }
            }
            it("should correctly parse lowercase") {
                expect(transform.transformFromJSON("ua")).to(equal("🇺🇦"))
            }
            it("should disregard non-country codes") {
                expect(transform.transformFromJSON("Hello world")).to(beNil())
            }
            it("should disregard non-country emojis") {
                expect(transform.transformToJSON("💃")).to(beNil())
            }
        }
    }
}
