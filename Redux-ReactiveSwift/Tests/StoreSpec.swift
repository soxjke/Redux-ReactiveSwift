//
//  StoreSpec.swift
//  Redux-ReactiveSwiftTests
//
//  Created by Petro Korienev on 10/15/17.
//  Copyright © 2017 Petro Korienev. All rights reserved.
//

import Quick
import Nimble
import ReactiveCocoa
import ReactiveSwift
import Redux_ReactiveSwift
import UIKit

extension Int: Defaultable {
    public static var defaultValue: Int {
        return 0
    }
}

class StoreSpec: QuickSpec {

    override func spec() {
        describe("Reducers processing") {
            context("single reducer") {
                it("should call reducer on event") {
                    let (store, reducer) = createStore(reducer: intReducer, initialValue: 0)
                    store.consume(event: .increment)
                    expect(reducer.callCount).to(equal(1))
                }
                it("should call reducer once on each event") {
                    let (store, reducer) = createStore(reducer: intReducer, initialValue: 0)
                    store.consume(event: .increment)
                    store.consume(event: .decrement)
                    store.consume(event: .add(1))
                    store.consume(event: .subtract(1))
                    expect(reducer.callCount).to(equal(4))
                }
                it("should fire signal on event") {
                    let (store, _) = createStore(reducer: intReducer, initialValue: 0)
                    let observer = observeValues(of: store, with: observeValues)
                    store.consume(event: .increment)
                    expect(observer.callCount).to(equal(1))
                }
                it("should fire signal on each event") {
                    let (store, _) = createStore(reducer: intReducer, initialValue: 0)
                    let observer = observeValues(of: store, with: observeValues)
                    store.consume(event: .increment)
                    store.consume(event: .decrement)
                    store.consume(event: .add(1))
                    store.consume(event: .subtract(1))
                    expect(observer.callCount).to(equal(4))
                }
            }
            context("multiple reducers") {
                it("should call every reducer once on event") {
                    let (store, reducer1, reducer2) = createStore(reducers: intReducer, intReducer, initialValue: 0)
                    store.consume(event: .increment)
                    expect(reducer1.callCount).to(equal(1))
                    expect(reducer2.callCount).to(equal(1))
                }
                it("should call every reducer once on each event") {
                    let (store, reducer1, reducer2) = createStore(reducers: intReducer, intReducer, initialValue: 0)
                    store.consume(event: .increment)
                    store.consume(event: .decrement)
                    store.consume(event: .add(1))
                    store.consume(event: .subtract(1))
                    expect(reducer1.callCount).to(equal(4))
                    expect(reducer2.callCount).to(equal(4))
                }
                it("should fire signal on event") {
                    let store = createStore(reducers: [intReducer, intReducer, intReducer], initialValue: 0)
                    let observer = observeValues(of: store, with: observeValues)
                    store.consume(event: .increment)
                    expect(observer.callCount).to(equal(1))
                }
                it("should fire signal on each event") {
                    let store = createStore(reducers: [intReducer, intReducer, intReducer], initialValue: 0)
                    let observer = observeValues(of: store, with: observeValues)
                    store.consume(event: .increment)
                    store.consume(event: .decrement)
                    store.consume(event: .add(1))
                    store.consume(event: .subtract(1))
                    expect(observer.callCount).to(equal(4))
                }
            }
        }
        describe("Value-type state") {
            context("value") {
                context("single reducer") {
                    it("should calculate value by reducer") {
                        let (store, _) = createStore(reducer: intReducer, initialValue: 0)
                        store.consume(event: .increment)
                        expect(store.value).to(equal(intReducer(state: 0, event: .increment)))
                    }
                    it("should calculate values by reducer on each event") {

                        let (store, _) = createStore(reducer: intReducer, initialValue: 0)
                        store.consume(event: .increment)
                        expect(store.value).to(equal(intReducer(state: 0, event: .increment)))

                        let state = store.value
                        store.consume(event: .decrement)
                        expect(store.value).to(equal(intReducer(state: state, event: .decrement)))
                    }
                }
                context("multiple reducers") {
                    let reducers = [intReducer, intReducer, intReducer]
                    it("should calculate value by reducer") {
                        let store = createStore(reducers: reducers, initialValue: 0)
                        store.consume(event: .increment)
                        let result = reducers.reduce(0, { state, reducer in reducer(state, .increment) })
                        expect(store.value).to(equal(result))
                    }
                    it("should calculate values by reducer on each event") {
                        let store = createStore(reducers: reducers, initialValue: 0)
                        store.consume(event: .increment)
                        let result = reducers.reduce(0, { state, reducer in reducer(state, .increment) })
                        expect(store.value).to(equal(result))

                        let state = store.value
                        store.consume(event: .decrement)
                        let nextResult = reducers.reduce(state, { state, reducer in reducer(state, .decrement) })
                        expect(store.value).to(equal(nextResult))
                    }
                }
            }
            context("signal producer") {
                it("should produce valid sequence of values") {
                    let (store, _) = createStore(reducer: intReducer, initialValue: 0)
                    let observer = observeValuesViaProducer(of: store, with: observeValues)

                    store.consume(event: .increment)
                    store.consume(event: .decrement)
                    store.consume(event: .add(1))
                    store.consume(event: .subtract(1))

                    let a = observer.arrayForAllCallsForArgument(at: 0)
                    expect((a as! [Int])).to(equal([0, 1, 0, 1, 0]))
                }
            }
        }
        describe("Reference-type state") {
            let initialState = 0 as NSNumber
            context("value") {
                context("single reducer") {
                    it("should calculate value by reducer") {
                        let (store, _) = createStore(reducer: nsNumberReducer, initialValue: initialState)
                        store.consume(event: .increment)
                        expect(store.value).to(equal(nsNumberReducer(state: initialState, event: .increment)))
                    }
                    it("should calculate values by reducer on each event") {
                        let (store, _) = createStore(reducer: nsNumberReducer, initialValue: initialState)
                        store.consume(event: .increment)
                        expect(store.value).to(equal(nsNumberReducer(state: initialState, event: .increment)))

                        let state = store.value
                        store.consume(event: .decrement)
                        expect(store.value).to(equal(nsNumberReducer(state: state, event: .decrement)))

                    }
                }
                context("multiple reducers") {
                    let reducers = [nsNumberReducer, nsNumberReducer, nsNumberReducer]
                    it("should calculate value by reducer") {
                        let store = createStore(reducers: reducers, initialValue: initialState)
                        store.consume(event: .increment)
                        let result = reducers.reduce(initialState, { state, reducer in reducer(state, .increment) })
                        expect(store.value).to(equal(result))
                    }

                    it("should calculate values by reducer on each event") {
                        let store = createStore(reducers: reducers, initialValue: initialState)
                        store.consume(event: .increment)
                        let result = reducers.reduce(initialState, { state, reducer in reducer(state, .increment) })
                        expect(store.value).to(equal(result))

                        let state = store.value
                        store.consume(event: .decrement)
                        let nextResult = reducers.reduce(state, { state, reducer in reducer(state, .decrement) })
                        expect(store.value).to(equal(nextResult))
                    }
                }
            }
            context("signal producer") {
                it("should produce valid sequence of values") {

                    let (store, _) = createStore(reducer: nsNumberReducer, initialValue: initialState)
                    let observer = observeValuesViaProducer(of: store, with: observeNumberValues)

                    store.consume(event: .increment)
                    store.consume(event: .decrement)
                    store.consume(event: .add(1))
                    store.consume(event: .subtract(1))

                    let a = observer.arrayForAllCallsForArgument(at: 0)
                    let expectedValues = [0, 1, 0, 1, 0].map { $0 as NSNumber }
                    expect((a as! [NSNumber])).to(equal([0, 1, 0, 1, 0]))

                }
            }
        }
        describe("Defaultable type state") {
            context("value") {
                it("should initialize with default value") {
                    let store: Store<Int, ()> = Store(reducers: [])
                    expect(store.value).to(equal(Int.defaultValue))
                }
            }
            context("signal producer") {
                it("should initialize with default value") {
                    let store: Store<Int, ()> = Store(reducers: [])
                    let observer = observeValuesViaProducer(of: store, with: observeValues)
                    expect((observer.arguments()[0] as! Int)).to(equal(Int.defaultValue))
                }
            }
        }
        describe("Value binding") {
            it("should deliver values to binding target") {
                let label = UILabel()
                let store = createStore(reducers: [stringReducer], initialValue: "Hello")
                label.reactive.text <~ store
                expect(label.text).to(equal("Hello"))
                store.consume(event: .increment)
                expect(label.text).to(equal("Hello1"))
                store.consume(event: .decrement)
                expect(label.text).to(equal("Hello"))
                store.consume(event: .add(4))
                expect(label.text).to(equal("Hello1234"))
                store.consume(event: .subtract(5))
                expect(label.text).to(equal("Hell"))
            }
            it("should accept values from the binding source") {
                let searchBar = UISearchBar()
                let searchSource = ["ReactiveCocoa", "ReactiveSwift", "Result", "Redux-ReactiveSwitft"]
                func reducer(state: [String], event: String) -> [String] {
                    return event.count > 0 ? searchSource.filter { $0.lowercased().starts(with: event.lowercased()) } : searchSource
                }
                let store = Store<[String], String>(state: [], reducers: [reducer])
                store <~ searchBar.reactive.continuousTextValues.skipNil()
                searchBar.text = "Re"
                searchBar.delegate?.searchBar?(searchBar, textDidChange: "Re")
                expect(store.value).to(equal(searchSource))
                searchBar.text = "Rea"
                searchBar.delegate?.searchBar?(searchBar, textDidChange: "Rea")
                expect(store.value).to(equal(["ReactiveCocoa", "ReactiveSwift"]))
                searchBar.text = "ReS"
                searchBar.delegate?.searchBar?(searchBar, textDidChange: "ReS")
                expect(store.value).to(equal(["Result"]))
                searchBar.text = "Red"
                searchBar.delegate?.searchBar?(searchBar, textDidChange: "Red")
                expect(store.value).to(equal(["Redux-ReactiveSwitft"]))
                searchBar.text = "RA"
                searchBar.delegate?.searchBar?(searchBar, textDidChange: "RA")
                expect(store.value).to(equal([]))
                searchBar.text = ""
                searchBar.delegate?.searchBar?(searchBar, textDidChange: "")
                expect(store.value).to(equal(searchSource))
            }
        }
    }

}

// MARK: Helpers

fileprivate enum IntegerArithmeticAction {
    case increment
    case decrement
    case add(Int)
    case subtract(Int)
}

private func createStore<State, Action>(reducer: @escaping (State, Action) -> State, initialValue: State) -> (Store<State, Action>, CallSpy) {
    let callSpy = CallSpy.makeCallSpy(f2: reducer)
    let store: Store<State,Action> = Store(state: initialValue, reducers: [callSpy.1])
    return (store, callSpy.0)
}

private func createStore<State, Action>(reducers first: @escaping (State, Action) -> State, _ second: @escaping (State, Action) -> State, initialValue: State) -> (Store<State, Action>, CallSpy, CallSpy) {
    let callSpy1 = CallSpy.makeCallSpy(f2: first)
    let callSpy2 = CallSpy.makeCallSpy(f2: second)

    let store: Store<State,Action> = Store(state: initialValue, reducers: [callSpy1.1, callSpy2.1])
    return (store, callSpy1.0, callSpy2.0)
}

private func createStore<State, Action>(reducers: [(State, Action) -> State], initialValue: State) -> (Store<State, Action>) {
    let store: Store<State,Action> = Store(state: initialValue, reducers: reducers)
    return store
}

private func observeValues<State, Action>(of store: Store<State, Action>, with observer: @escaping (State) -> ()) -> CallSpy  {
    let callSpy = CallSpy.makeCallSpy(f1: observer)
    store.signal.observeValues(callSpy.1)
    return callSpy.0
}

private func observeValuesViaProducer<State, Action>(of store: Store<State, Action>, with observer: @escaping (State) -> ()) -> CallSpy  {
    let callSpy = CallSpy.makeCallSpy(f1: observer)
    store.producer.startWithValues(callSpy.1)
    return callSpy.0
}

private func intReducer(state: Int, event: IntegerArithmeticAction) -> Int {
    switch event {
    case .increment: return state + 1;
    case .decrement: return state - 1;
    case .add(let operand): return state + operand;
    case .subtract(let operand): return state - operand;
    }
}
private func nsNumberReducer(state: NSNumber, event: IntegerArithmeticAction) -> NSNumber {
    switch event {
    case .increment: return NSNumber(integerLiteral: state.intValue + 1);
    case .decrement: return NSNumber(integerLiteral: state.intValue - 1);
    case .add(let operand): return NSNumber(integerLiteral: state.intValue + operand);
    case .subtract(let operand): return NSNumber(integerLiteral: state.intValue - operand);
    }
}
private func stringReducer(state: String, event: IntegerArithmeticAction) -> String {
    switch event {
    case .increment: return state + "1";
    case .decrement: return String(state.dropLast());
    case .add(let operand): return state + (1...operand).map {"\($0)"}.joined(separator: "");
    case .subtract(let operand): return String(state.dropLast(operand));
    }
}
private func observeValues(values: Int) {}
private func observeNumberValues(values: NSNumber) {}
