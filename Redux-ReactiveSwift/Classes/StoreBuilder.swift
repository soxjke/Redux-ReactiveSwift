//
//  StoreBuilder.swift
//  Redux-ReactiveSwift
//
//  Created by Petro Korienev on 1/1/18.
//

import Foundation
import ReactiveSwift

open class StoreBuilder<StateType, EventType, StoreType: Store<StateType, EventType>> {
    
    fileprivate var initialState: StateType
    fileprivate var reducers: [StoreType.Reducer] = []
    fileprivate var middlewares: [StoreMiddleware] = []
    
    public init(state: StateType) {
        initialState = state
    }
    
    public func build() -> StoreType {
        return StoreType(state: initialState, reducers: reducers).applyMiddlewares(middlewares)
    }
    
    public func verboseBuild()
        -> (store: StoreType, middlewares: [StoreMiddleware], reducers: [StoreType.Reducer]) {
        return (store: build(), middlewares: middlewares, reducers: reducers)
    }
}

public extension StoreBuilder where StateType: Defaultable {
    convenience init() {
        self.init(state: StateType.defaultValue)
    }
}

// MARK: Builder DSL

typealias MiddlewareBuilder = StoreBuilder
public extension MiddlewareBuilder {
    public func middleware(_ middleware: StoreMiddleware) {
        middlewares.append(middleware)
    }
}

typealias ReducerBuilder = StoreBuilder
public extension ReducerBuilder {
    public func reducer(_ reducer: @escaping (StateType, EventType) -> (StateType)) {
        reducers.append(reducer)
    }
}

typealias LoggerBuilder = StoreBuilder
public extension LoggerBuilder {
    public func logger(log: @escaping (String) -> (), flags: LoggerFlags = .logAll, name: String? = nil) {
        middlewares.append(Logger(log: log, flags: flags, name: name))
    }
    public func nslogger(flags: LoggerFlags = .logAll, name: String? = "Redux-ReactiveSwift-NSLogger") {
        middlewares.append(Logger(log: { NSLog($0) }, flags: flags, name: name))
    }
    public func nsloggerDebug(flags: LoggerFlags = .logAll, name: String? = "Redux-ReactiveSwift-NSLogger-Debug") {
#if DEBUG
        middlewares.append(Logger(log: { NSLog($0) }, flags: flags, name: name))
#endif
    }
}

typealias DispatcherBuilder = StoreBuilder
public extension DispatcherBuilder {
    public func dispatcher(queue: DispatchQueue = DispatchQueue(label:"Redux-ReactiveSwift.Dispatcher"),
                           qos: DispatchQoS = .default,
                           name: String = "Redux-ReactiveSwift.Dispatcher") {
        middlewares.append(Dispatcher(queue: queue, qos: qos, name: name))
    }
    public func dispatcher(scheduler: Scheduler) {
        middlewares.append(Dispatcher(scheduler: scheduler))
    }
}

typealias PersisterBuilder = StoreBuilder
public extension PersisterBuilder where StateType: Persistable {
    public func jsonFilePersister(url: URL = JSONFilePersister<StateType>.defaultPersisterURL(),
                                  writerQueue: DispatchQueue = DispatchQueue(label: "Redux-ReactiveSwift.JSONFilePersister")) {
        middlewares.append(JSONFilePersister<StateType>(url: url, writerQueue: writerQueue))
    }
}
