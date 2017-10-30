//
//  WeatherSpec.swift
//  Simple-Weather-AppTests
//
//  Created by Petro Korienev on 10/26/17.
//  Copyright © 2017 Sigma Software. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import Simple_Weather_App

class WeatherSpec: QuickSpec {
    override func spec() {
        let weatherJSON: [String: Any] = try! JSONSerialization.jsonObject(with: try! Data.init(contentsOf: Bundle.test.url(forResource: "Weather", withExtension: "json")!)) as! [String: Any]
        describe("parsing") {
            let weather = try? Weather(JSON: weatherJSON)
            it("should parse weather") {
                expect(weather).notTo(beNil())
            }
            it("should parse precipitation probability") {
                expect(weather!.day.precipitationProbability).to(equal(12))
                expect(weather!.night.precipitationProbability).to(equal(1))
            }
            it("should parse time") {
                expect(weather!.effectiveDate.timeIntervalSince1970).to(beCloseTo(1508997600))
            }
            it("should parse temperature") {
                expect(weather!.temperature.unit).to(equal("F"))
                if case .minmax(let min, let max) = weather!.temperature.value {
                    expect(min).to(beCloseTo(71)) // note matcher beCloseTo used for Double
                    expect(max).to(beCloseTo(76)) // comparing Doubles by equality is incorrect
                } else {
                    fail("parsed temperature is not in minmax format")
                }
            }
            it("should parse RealFeel temperature") {
                expect(weather!.realFeel.unit).to(equal("F"))
                if case .minmax(let min, let max) = weather!.realFeel.value {
                    expect(min).to(beCloseTo(71))
                    expect(max).to(beCloseTo(78))
                } else {
                    fail("parsed RealFeel temperature is not in minmax format")
                }
            }
            it("should parse icon") {
                expect(weather!.day.icon).to(equal(4))
                expect(weather!.night.icon).to(equal(34))
            }
            it("should parse phrase") {
                expect(weather!.day.phrase).to(equal("Humid with sun through high clouds"))
                expect(weather!.night.phrase).to(equal("Mainly clear and humid"))
            }
            it("should parse wind direction") {
                expect(weather!.day.windDirection).to(equal("S"))
                expect(weather!.night.windDirection).to(equal("SSE"))
            }
            it("should parse wind speed") {
                expect(weather!.day.windSpeed.unit).to(equal("mi/h"))
                if case .single(let value) = weather!.day.windSpeed.value {
                    expect(value).to(beCloseTo(11.5))
                } else {
                    fail("parsed day wind speed is not in single format")
                }
                expect(weather!.night.windSpeed.unit).to(equal("mi/h"))
                if case .single(let value) = weather!.night.windSpeed.value {
                    expect(value).to(beCloseTo(9.2))
                } else {
                    fail("parsed night wind speed is not in single format")
                }
            }
        }
    }
}

class CurrentWeatherSpec: QuickSpec {
    override func spec() {
        let weatherJSON: [String: Any] = try! JSONSerialization.jsonObject(with: try! Data.init(contentsOf: Bundle.test.url(forResource: "CurrentWeather", withExtension: "json")!)) as! [String: Any]
        describe("parsing") {
            let weather = try? CurrentWeather(JSON: weatherJSON)
            it("should parse weather") {
                expect(weather).notTo(beNil())
            }
            it("should parse phrase") {
                expect(weather!.phrase).to(equal("Cloudy"))
            }
            it("should parse icon") {
                expect(weather!.icon).to(equal(7))
            }
            it("should parse wind direction") {
                expect(weather!.windDirection).to(equal("S"))
            }
            it("should parse time") {
                expect(weather!.effectiveDate.timeIntervalSince1970).to(beCloseTo(1509536700))
            }
            
            // Locale-specific tests. To avoid conditionals, we're skipping imperial locale
            guard Locale.current.usesMetricSystem else { return }
            it("should parse temperature") {
                expect(weather!.temperature.unit).to(equal("C"))
                if case .single(let value) = weather!.temperature.value {
                    expect(value).to(beCloseTo(22))
                } else {
                    fail("parsed temperature is not single value")
                }
            }
            it("should parse RealFeel temperature") {
                expect(weather!.realFeel.unit).to(equal("C"))
                if case .single(let value) = weather!.realFeel.value {
                    expect(value).to(beCloseTo(20.4))
                } else {
                    fail("parsed RealFeel temperature is not single value")
                }
            }
            it("should parse wind speend") {
                expect(weather!.windSpeed.unit).to(equal("km/h"))
                if case .single(let value) = weather!.windSpeed.value {
                    expect(value).to(beCloseTo(9.4))
                } else {
                    fail("parsed wind speed is not single value")
                }
            }
        }
    }
}
