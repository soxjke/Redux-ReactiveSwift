//
//  StoreMiddleware.swift
//  Redux-ReactiveSwift
//
//  Created by Petro Korienev on 1/1/18.
//

import Foundation
import ReactiveSwift
import Result

public protocol StoreMiddleware {
    func consume<Event>(event: Event) -> Signal<Event, NoError>?
    func stateDidChange<State>(state: State)
    func unsafeValue() -> Signal<Any, NoError>?
}
