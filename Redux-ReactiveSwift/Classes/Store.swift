//
//  Store.swift
//  Redux-ReactiveSwift
//
//  Created by Petro Korienev on 10/12/17.
//  Copyright © 2017 Petro Korienev. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

public protocol Defaultable {
    static var defaultValue: Self { get }
}

infix operator <~ : BindingPrecedence

open class Store<State, Event> {
    
    public typealias Reducer = (State, Event) -> State
    
    fileprivate var innerProperty: MutableProperty<State>
    fileprivate var reducers: [Reducer]
    
    public required init(state: State, reducers: [Reducer]) {
        self.innerProperty = MutableProperty<State>(state)
        self.reducers = reducers
    }
    
    public func consume(event: Event) {
        self.innerProperty.value = reducers.reduce(self.innerProperty.value) { $1($0, event) }
    }
}

extension Store: PropertyProtocol {
    public var value: State {
        return innerProperty.value
    }
    public var producer: SignalProducer<State, NoError> {
        return innerProperty.producer
    }
    public var signal: Signal<State, NoError> {
        return innerProperty.signal
    }
}

public extension Store {
    @discardableResult
    public static func <~ <Source: BindingSource> (target: Store<State, Event>, source: Source) -> Disposable?
        where Event == Source.Value
    {
        return source.producer
            .take(during: target.innerProperty.lifetime)
            .startWithValues(target.consume)
    }
}

public extension Store where State: Defaultable {
    convenience init(reducers: [Reducer]) {
        self.init(state: State.defaultValue, reducers: reducers)
    }
}
