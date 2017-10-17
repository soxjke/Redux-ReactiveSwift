//
//  StoreSpec.swift
//  Redux-ReactiveSwift
//
//  Created by Petro Korienev on 10/15/17.
//  Copyright © 2017 Sigma Software. All rights reserved.
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
    private enum IntegerArithmeticAction {
        case increment
        case decrement
        case add(Int)
        case subtract(Int)
    }
    override func spec() {
        func testReduce(state: Int, event: IntegerArithmeticAction) -> Int {
            switch event {
            case .increment: return state + 1;
            case .decrement: return state - 1;
            case .add(let operand): return state + operand;
            case .subtract(let operand): return state - operand;
            }
        }
        func testReduce1(state: NSNumber, event: IntegerArithmeticAction) -> NSNumber {
            switch event {
            case .increment: return NSNumber(integerLiteral: state.intValue + 1);
            case .decrement: return NSNumber(integerLiteral: state.intValue - 1);
            case .add(let operand): return NSNumber(integerLiteral: state.intValue + operand);
            case .subtract(let operand): return NSNumber(integerLiteral: state.intValue - operand);
            }
        }
        func testReduce2(state: String, event: IntegerArithmeticAction) -> String {
            switch event {
            case .increment: return state + "1";
            case .decrement: return String(state.dropLast());
            case .add(let operand): return state + (1...operand).map {"\($0)"}.joined(separator: "");
            case .subtract(let operand): return String(state.dropLast(operand));
            }
        }
        func observeValues(values: Int) {}
        func observeNumberValues(values: NSNumber) {}
        
        describe("Reducers processing") {
            context("single reducer") {
                it("should call reducer on event") {
                    let callSpy = CallSpy.makeCallSpy(f2: testReduce)
                    let store: Store<Int, IntegerArithmeticAction> = Store(state: 0, reducers: [callSpy.1])
                    store.consume(event: .increment)
                    expect(callSpy.0.callCount).to(equal(1))
                }
                it("should call reducer once on each event") {
                    let callSpy = CallSpy.makeCallSpy(f2: testReduce)
                    let store: Store<Int, IntegerArithmeticAction> = Store(state: 0, reducers: [callSpy.1])
                    store.consume(event: .increment)
                    store.consume(event: .decrement)
                    store.consume(event: .add(1))
                    store.consume(event: .subtract(1))
                    expect(callSpy.0.callCount).to(equal(4))
                }
                it("should fire signal on event") {
                    let callSpy = CallSpy.makeCallSpy(f1: observeValues)
                    let store: Store<Int, IntegerArithmeticAction> = Store(state: 0, reducers: [testReduce])
                    store.signal.observeValues(callSpy.1)
                    store.consume(event: .increment)
                    expect(callSpy.0.callCount).to(equal(1))
                }
                it("should fire signal on each event") {
                    let callSpy = CallSpy.makeCallSpy(f1: observeValues)
                    let store: Store<Int, IntegerArithmeticAction> = Store(state: 0, reducers: [testReduce])
                    store.signal.observeValues(callSpy.1)
                    store.consume(event: .increment)
                    store.consume(event: .decrement)
                    store.consume(event: .add(1))
                    store.consume(event: .subtract(1))
                    expect(callSpy.0.callCount).to(equal(4))
                }
            }
            context("multiple reducers") {
                it("should call every reducer once on event") {
                    let callSpy1 = CallSpy.makeCallSpy(f2: testReduce)
                    let callSpy2 = CallSpy.makeCallSpy(f2: testReduce)
                    let store: Store<Int, IntegerArithmeticAction> = Store(state: 0, reducers: [callSpy1.1, callSpy2.1])
                    store.consume(event: .increment)
                    expect(callSpy1.0.callCount).to(equal(1))
                    expect(callSpy2.0.callCount).to(equal(1))
                }
                it("should call every reducer once on each event") {
                    let callSpy1 = CallSpy.makeCallSpy(f2: testReduce)
                    let callSpy2 = CallSpy.makeCallSpy(f2: testReduce)
                    let store: Store<Int, IntegerArithmeticAction> = Store(state: 0, reducers: [callSpy1.1, callSpy2.1])
                    store.consume(event: .increment)
                    store.consume(event: .decrement)
                    store.consume(event: .add(1))
                    store.consume(event: .subtract(1))
                    expect(callSpy1.0.callCount).to(equal(4))
                    expect(callSpy2.0.callCount).to(equal(4))
                }
                it("should fire signal on event") {
                    let callSpy = CallSpy.makeCallSpy(f1: observeValues)
                    let store: Store<Int, IntegerArithmeticAction> = Store(state: 0, reducers: [testReduce, testReduce, testReduce])
                    store.signal.observeValues(callSpy.1)
                    store.consume(event: .increment)
                    expect(callSpy.0.callCount).to(equal(1))
                }
                it("should fire signal on each event") {
                    let callSpy = CallSpy.makeCallSpy(f1: observeValues)
                    let store: Store<Int, IntegerArithmeticAction> = Store(state: 0, reducers: [testReduce, testReduce, testReduce])
                    store.signal.observeValues(callSpy.1)
                    store.consume(event: .increment)
                    store.consume(event: .decrement)
                    store.consume(event: .add(1))
                    store.consume(event: .subtract(1))
                    expect(callSpy.0.callCount).to(equal(4))
                }
            }
        }
        describe("Value-type state") {
            context("value") {
                context("single reducer") {
                    it("should calculate value by reducer") {
                        let state = 0
                        let event = IntegerArithmeticAction.increment
                        let store: Store<Int, IntegerArithmeticAction> = Store(state: state, reducers: [testReduce])
                        store.consume(event: event)
                        expect(store.value).to(equal(testReduce(state: state, event: event)))
                    }
                    it("should calculate values by reducer on each event") {
                        var state = 0
                        var event = IntegerArithmeticAction.increment
                        let store: Store<Int, IntegerArithmeticAction> = Store(state: state, reducers: [testReduce])
                        store.consume(event: event)
                        expect(store.value).to(equal(testReduce(state: state, event: event)))
                        state = store.value
                        event = .decrement
                        store.consume(event: event)
                        expect(store.value).to(equal(testReduce(state: state, event: event)))
                    }
                }
                context("multiple reducers") {
                    let reducers = [testReduce, testReduce, testReduce]
                    it("should calculate value by reducer") {
                        let state = 0
                        let event = IntegerArithmeticAction.increment
                        let store: Store<Int, IntegerArithmeticAction> = Store(state: state, reducers: reducers)
                        store.consume(event: event)
                        var result = state
                        for reducer in reducers {
                            result = reducer(result, event)
                        }
                        expect(store.value).to(equal(result))
                    }
                    it("should calculate values by reducer on each event") {
                        var state = 0
                        var event = IntegerArithmeticAction.increment
                        let store: Store<Int, IntegerArithmeticAction> = Store(state: state, reducers: reducers)
                        var result = state
                        for reducer in reducers {
                            result = reducer(result, event)
                        }
                        store.consume(event: event)
                        expect(store.value).to(equal(result))
                        state = store.value
                        event = .decrement
                        result = state
                        for reducer in reducers {
                            result = reducer(result, event)
                        }
                        store.consume(event: event)
                        expect(store.value).to(equal(result))
                    }
                }
            }
            context("signal producer") {
                it("should produce valid sequence of values") {
                    let store: Store<Int, IntegerArithmeticAction> = Store(state: 0, reducers: [testReduce])
                    let callSpy = CallSpy.makeCallSpy(f1: observeValues)
                    store.producer.startWithValues(callSpy.1)
                    store.consume(event: .increment)
                    store.consume(event: .decrement)
                    store.consume(event: .add(1))
                    store.consume(event: .subtract(1))
                    let a = callSpy.0.arrayForAllCallsForArgument(at: 0)
                    expect((a as! [Int])).to(equal([0, 1, 0, 1, 0]))
                }
            }
        }
        describe("Reference-type state") {
            context("value") {
                context("single reducer") {
                    it("should calculate value by reducer") {
                        let state = NSNumber(integerLiteral: 0)
                        let event = IntegerArithmeticAction.increment
                        let store: Store<NSNumber, IntegerArithmeticAction> = Store(state: state, reducers: [testReduce1])
                        store.consume(event: event)
                        expect(store.value).to(equal(testReduce1(state: state, event: event)))
                    }
                    it("should calculate values by reducer on each event") {
                        var state = NSNumber(integerLiteral: 0)
                        var event = IntegerArithmeticAction.increment
                        let store: Store<NSNumber, IntegerArithmeticAction> = Store(state: state, reducers: [testReduce1])
                        store.consume(event: event)
                        expect(store.value).to(equal(testReduce1(state: state, event: event)))
                        state = store.value
                        event = .decrement
                        store.consume(event: event)
                        expect(store.value).to(equal(testReduce1(state: state, event: event)))
                    }
                }
                context("multiple reducers") {
                    let reducers = [testReduce1, testReduce1, testReduce1]
                    it("should calculate value by reducer") {
                        let state = NSNumber(integerLiteral: 0)
                        let event = IntegerArithmeticAction.increment
                        let store: Store<NSNumber, IntegerArithmeticAction> = Store(state: state, reducers: reducers)
                        store.consume(event: event)
                        var result = state
                        for reducer in reducers {
                            result = reducer(result, event)
                        }
                        expect(store.value).to(equal(result))
                    }
                    it("should calculate values by reducer on each event") {
                        var state = NSNumber(integerLiteral: 0)
                        var event = IntegerArithmeticAction.increment
                        let store: Store<NSNumber, IntegerArithmeticAction> = Store(state: state, reducers: reducers)
                        var result = state
                        for reducer in reducers {
                            result = reducer(result, event)
                        }
                        store.consume(event: event)
                        expect(store.value).to(equal(result))
                        state = store.value
                        event = .decrement
                        result = state
                        for reducer in reducers {
                            result = reducer(result, event)
                        }
                        store.consume(event: event)
                        expect(store.value).to(equal(result))
                    }
                }
            }
            context("signal producer") {
                it("should produce valid sequence of values") {
                    let store: Store<NSNumber, IntegerArithmeticAction> = Store(state: NSNumber(integerLiteral: 0), reducers: [testReduce1])
                    let callSpy = CallSpy.makeCallSpy(f1: observeNumberValues)
                    store.producer.startWithValues(callSpy.1)
                    store.consume(event: .increment)
                    store.consume(event: .decrement)
                    store.consume(event: .add(1))
                    store.consume(event: .subtract(1))
                    let a = callSpy.0.arrayForAllCallsForArgument(at: 0)
                    expect((a as! [NSNumber])).to(equal([NSNumber(integerLiteral: 0), NSNumber(integerLiteral: 1), NSNumber(integerLiteral: 0), NSNumber(integerLiteral: 1), NSNumber(integerLiteral: 0)]))
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
                    let callSpy = CallSpy.makeCallSpy(f1: observeValues)
                    store.producer.startWithValues(callSpy.1)
                    expect((callSpy.0.arguments()[0] as! Int)).to(equal(Int.defaultValue))
                }
            }
        }
        describe("Value binding") {
            it("should deliver values to binding target") {
                let label = UILabel()
                let store: Store<String, IntegerArithmeticAction> = Store(state: "Hello", reducers: [testReduce2])
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
                    return event.characters.count > 0 ? searchSource.filter { $0.lowercased().starts(with: event.lowercased()) } : searchSource
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
