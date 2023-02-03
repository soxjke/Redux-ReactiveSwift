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
    fileprivate var middlewares: [StoreMiddleware] = []
    
    public required init(state: State, reducers: [Reducer]) {
        self.innerProperty = MutableProperty<State>(state)
        self.reducers = reducers
    }
    
    public func applyMiddlewares(_ middlewares: [StoreMiddleware]) -> Self {
        guard self.middlewares.count == 0 else { fatalError("Applying middlewares more than once is yet unsupported") }
        self.middlewares = middlewares
        self.middlewares.forEach(self.register(middleware:))
        return self
    }
    
    public func consume(event: Event) {
        consume(event: event, with: middlewares)
    }
    
    private func consume(event: Event, with middlewares: [StoreMiddleware]) {
        guard middlewares.count > 0 else { return undecoratedConsume(event: event) }
        let slicedMiddlewares = Array(middlewares.dropFirst())
        if let signal = middlewares.first?.consume(event: event)?.take(first: 1) {
            signal.observeValues { [weak self] value in self?.consume(event: event, with: slicedMiddlewares) }
        }
        else {
            self.consume(event: event, with: slicedMiddlewares)
        }
    }
    
    public func undecoratedConsume(event: Event) {
        self.innerProperty.value = reducers.reduce(self.innerProperty.value) { $1($0, event) }
    }
    
    private func register(middleware: StoreMiddleware) {
        self.innerProperty.signal.observeValues { middleware.stateDidChange(state: $0) }
        middleware.unsafeValue()?.observeValues { [weak self] value in
            guard let safeValue = value as? State else {
                fatalError("Store got \(value) from unsafeValue() signal which is not of \(String(describing:State.self)) type")
            }
            self?.innerProperty.value = safeValue
        }
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
