//
//  Weather.swift
//  Simple-Weather-App
//
//  Created by Petro Korienev on 10/26/17.
//  Copyright © 2017 Sigma Software. All rights reserved.
//

import Foundation
import ObjectMapper

enum WeatherValue<Value> {
    case single(value: Value)
    case minmax(min: Value, max: Value)
}

struct WeatherFeature<T> {
    let unit: String
    let value: WeatherValue<T>
}

struct DayNightWeather {
    let windSpeed: WeatherFeature<Double>
    let windDirection: String
    let precipitationProbability: Int
    let phrase: String
    let icon: Int
}

// Since Swift 3.1 there's a neat feature called "Type nesting with generics" is
// around, however implementation is buggy and leads to runtime error
// https://bugs.swift.org/browse/SR-4383
// As a workaround, WeatherValue, WeatherFeature, DayNightWeather are standalone types
struct Weather {
    let effectiveDate: Date
    let temperature: WeatherFeature<Double>
    let realFeel: WeatherFeature<Double>
    let day: DayNightWeather
    let night: DayNightWeather
}

extension Weather: ImmutableMappable {
    init(map: Map) throws {
        effectiveDate = try map.value("EpochDate", using: DateTransform())
        temperature = try map.value("Temperature")
        realFeel = try map.value("RealFeelTemperature")
        day = try map.value("Day")
        night = try map.value("Night")
    }
    func mapping(map: Map) {
    }
}

extension WeatherFeature: ImmutableMappable {
    init(map: Map) throws {
        if let minimum: T = try? map.value("Minimum.Value"),
            let maximum: T = try? map.value("Maximum.Value") { // Min/max
            unit = try map.value("Minimum.Unit")
            value = .minmax(min: minimum, max: maximum)
        }
        else { // Single value
            unit = try map.value("Unit")
            value = .single(value: try map.value("Value"))
        }
            
    }
    func mapping(map: Map) {
    }
}

extension DayNightWeather: ImmutableMappable {
    init(map: Map) throws {
        windSpeed = try map.value("Wind.Speed")
        windDirection = (try? map.value("Wind.Direction.Localized")) ?? ((try? map.value("Wind.Direction.English")) ?? "")
        precipitationProbability = try map.value("PrecipitationProbability")
        phrase = try map.value("LongPhrase")
        icon = try map.value("Icon")
    }
    func mapping(map: Map) {
    }
}

struct CurrentWeather {
    let effectiveDate: Date
    let phrase: String
    let icon: Int
    let temperature: WeatherFeature<Double>
    let realFeel: WeatherFeature<Double>
    let windSpeed: WeatherFeature<Double>
    let windDirection: String
}

extension CurrentWeather: ImmutableMappable {
    private static let UnitSystem = Locale.current.usesMetricSystem ? "Metric" : "Imperial"
    init(map: Map) throws {
        effectiveDate = try map.value("EpochTime", using: DateTransform())
        temperature = try map.value("Temperature.\(CurrentWeather.UnitSystem)")
        realFeel = try map.value("RealFeelTemperature.\(CurrentWeather.UnitSystem)")
        windSpeed = try map.value("Wind.Speed.\(CurrentWeather.UnitSystem)")
        windDirection = (try? map.value("Wind.Direction.Localized")) ?? ((try? map.value("Wind.Direction.English")) ?? "")
        phrase = try map.value("WeatherText")
        icon = try map.value("WeatherIcon")
    }
    func mapping(map: Map) {
    }
}
