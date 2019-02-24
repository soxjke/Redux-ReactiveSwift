//
//  Dispatcher.swift
//  Redux-ReactiveSwift
//
//  Created by Petro Korienev on 1/1/18.
//

import Foundation
import ReactiveSwift
import Result

public class Dispatcher: StoreMiddleware {
    
    private let scheduler: Scheduler
    
    public init(queue: DispatchQueue,
                qos: DispatchQoS,
                name: String) {
        scheduler = QueueScheduler(qos: qos, name: name, targeting: queue)
    }
    
    public init(scheduler: Scheduler) {
        self.scheduler = scheduler
    }
    
    public func consume<Event>(event: Event) -> Signal<Event, NoError>? {
        let pipe = Signal<Event, NoError>.pipe()
        defer { pipe.input.send(value: event) }
        return pipe.output.observe(on: scheduler)
    }
    
    // MARK: Protocol stubs unused for this middleware
    public func stateDidChange<State>(state: State) {}
    public func unsafeValue() -> Signal<Any, NoError>? { return nil }
}
