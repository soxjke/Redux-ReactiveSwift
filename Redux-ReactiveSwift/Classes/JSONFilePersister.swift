//
//  JSONFilePersister.swift
//  Redux-ReactiveSwift
//
//  Created by Petro Korienev on 1/1/18.
//

import Foundation
import ReactiveSwift
import Result

public class JSONFilePersister<State: Persistable>: Persister {
    
    let url: URL
    let writerQueue: DispatchQueue
    
    init(url: URL, writerQueue: DispatchQueue) {
        self.url = url;
        self.writerQueue = writerQueue
    }
    
    public func persist(dictionary: [String : Any]) {
        writerQueue.async { [url] in
            guard let data = try? JSONSerialization.data(withJSONObject: dictionary) else { return }
            try? data.write(to: url)
        }
    }
    
    public func restore() -> [String : Any]? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        guard let object = try? JSONSerialization.jsonObject(with: data) else { return nil }
        return object as? [String : Any]
    }
    
    public func unsafeValue() -> Signal<Any, NoError>? {
        guard let restored = restore() else { return nil }
        guard let deserialized = State.deserialize(from: restored) else { return nil }
        return Signal { observer, _ in
            observer.send(value: deserialized)
            observer.sendCompleted()
        }
    }
}
