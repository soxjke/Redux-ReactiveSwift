//
//  CallSpy.swift
//  Redux-ReactiveSwiftTests
//
//  Created by Petro Korienev on 10/17/17.
//  Copyright © 2017 Petro Korienev. All rights reserved.
//

import Foundation

extension Array {
    var mutatingLast: Element? {
        get {
            return last
        }
        set {
            if let newValue = newValue, let _ = last { removeLast(); append(newValue) }
        }
    }
}

class CallSpy {
    
    private struct CallLogEntry {
        private static let argLabel = "arg"
        private static let retLabel = "ret"
        private var innerDict : [String: Any] = [:]
        private var resultDict: [String: Any] = [:]
        mutating func setArgs(_ args: Any...) {
            var i: Int = 0
            for arg in args {
                innerDict[CallLogEntry.makeArgKey(i)] = arg
                i = i + 1
            }
        }
        mutating func setArgsArray(_ args: [Any]) {
            var i: Int = 0
            for arg in args {
                innerDict[CallLogEntry.makeArgKey(i)] = arg
                i = i + 1
            }
        }
        mutating func setResult(_ result: Any) {
            resultDict[CallLogEntry.retLabel] = result
        }
        private static func makeArgKey(_ arg: Int) -> String {
            return "\(CallLogEntry.argLabel)\(arg)"
        }
        var argumentsArray: [Any] {
            return innerDict.values.map { $0 }
        }
        var retVal: Any? {
            return resultDict[CallLogEntry.retLabel]
        }
    }
    
    private var callLog: [CallLogEntry] = []
    private var beforeCall: (() -> ())?
    private var afterCall: (() -> ())?
    static func makeCallSpy<RetType, T0>(f1: @escaping (T0) -> RetType) -> (CallSpy, (T0) -> RetType) {
        let callable = CallSpy()
        return (callable, { (arg0: T0) -> RetType in
            callable.beforeCall?()
            callable.appendCall()
            callable.appendArgs(arg0)
            let result: RetType = f1(arg0)
            callable.appendRetVal(result)
            callable.afterCall?()
            return result
        })
    }
    static func makeCallSpy<RetType, T0, T1>(f2: @escaping (T0, T1) -> RetType) -> (CallSpy, (T0, T1) -> RetType) {
        let callable = CallSpy()
        return (callable, { (arg0: T0, arg1: T1) -> RetType in
            callable.beforeCall?()
            callable.appendCall()
            callable.appendArgs(arg0, arg1)
            let result: RetType = f2(arg0, arg1)
            callable.appendRetVal(result)
            callable.afterCall?()
            return result
        })
    }
    private func appendCall() { callLog.append(CallLogEntry())}
    private func appendArgs(_ args: Any...) { callLog.mutatingLast?.setArgsArray(args) }
    private func appendRetVal(_ retVal: Any) { callLog.mutatingLast?.setResult(retVal) }
    
    var callCount: Int {
        return callLog.count
    }
    func arguments(of call: Int = 0) -> [Any] {
        return callLog[call].argumentsArray
    }
    func arrayForAllCallsForArgument(at index:Int) -> [Any] {
        return callLog.map { $0.argumentsArray[index] }
    }
    func retVal(of call: Int = 0) -> Any? {
        return callLog[call].retVal
    }
    func arrayForAllCallsForRetVal() -> [Any?] {
        return callLog.map { $0.retVal }
    }
}
