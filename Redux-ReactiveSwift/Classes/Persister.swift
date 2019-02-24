//
//  Persister.swift
//  Redux-ReactiveSwift
//
//  Created by Petro Korienev on 1/1/18.
//

import Foundation
import ReactiveSwift
import Result

public protocol Serializable {
    func serialize() -> [String: Any]
    static func deserialize(`from` dictionary: [String: Any]) -> Self?
}

public protocol Persistable: Serializable {
    func shouldPersist() -> Bool
}

public protocol Persister: StoreMiddleware {
    func persist(dictionary: [String: Any])
    func restore() -> [String: Any]?
}

extension Persister {
    public func stateDidChange<State>(state: State) {
        guard let persistable = state as? Persistable else {
            fatalError("\(String(describing: State.self)) is asked to be persisted by \(self) middleware but it's not of Persistable type ") }
        guard persistable.shouldPersist() else { return }
        persist(dictionary: persistable.serialize())
    }
    
    public static func defaultPersisterURL() -> URL {
        guard let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first else {
            fatalError("Cannot find requested default caches folder path")
        }
        return URL(fileURLWithPath: cachePath.appending("Redux-ReactiveSwift.\(String(describing: Self.self)).json"))
    }
    
    // MARK: Protocol stubs unused for this middleware
    public func consume<Event>(event: Event) -> Signal<Event, NoError>? { return nil }
}
