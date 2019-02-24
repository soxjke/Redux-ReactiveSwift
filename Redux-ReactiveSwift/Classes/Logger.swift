//
//  Logger.swift
//  Redux-ReactiveSwift
//
//  Created by Petro Korienev on 1/1/18.
//

import Foundation
import ReactiveSwift
import Result

public struct LoggerFlags: OptionSet {
    public let rawValue: Int
    
    public static let logEvents = LoggerFlags(rawValue: 1 << 0)
    public static let logStates = LoggerFlags(rawValue: 1 << 1)
    
    public static let logAll: LoggerFlags = [.logEvents, .logStates]
    
    public init(rawValue: Int) { self.rawValue = rawValue }
}

public class Logger: StoreMiddleware {
    
    private let log: (String) -> ()
    private let flags: LoggerFlags
    private let name: String?
    
    public init(log: @escaping (String) -> (), flags: LoggerFlags = .logAll, name: String? = nil) {
        self.log = log
        self.flags = flags
        self.name = name
    }
    
    public func consume<Event>(event: Event) -> Signal<Event, NoError>? {
        if flags.contains(.logEvents) { log(format(eventOrState: event, flags: [.logEvents])) }
        return Signal { observer, _ in
            observer.send(value: event)
            observer.sendCompleted()
        }
    }
    
    public func stateDidChange<State>(state: State) {
        if flags.contains(.logStates) { log(format(eventOrState: state, flags: [.logStates])) }
    }
    
    // MARK: Protocol stubs unused for this middleware
    public func unsafeValue() -> Signal<Any, NoError>? { return nil }
    
    // MARK: Private formatting stuff
    private func name(_ string: String) -> String {
        guard let name = name else { return string }
        return "\(name): \(string)"
    }
    
    private func format<T>(eventOrState: T, flags: LoggerFlags) -> String {
        let valueString = toString(eventOrState: eventOrState)
        if flags.contains(.logEvents) { return "Consumed event: \(valueString)" }
        if flags.contains(.logStates) { return "Switched state: \(valueString)" }
        fatalError("format is called with wrong flags set")
    }
    
    private func toString<T>(eventOrState: T) -> String {
        guard let s = eventOrState as? CustomStringConvertible else { return "\(eventOrState)" }
        return s.description
    }
}
