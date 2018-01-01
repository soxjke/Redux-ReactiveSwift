//
//  StoreBuilderSpec.swift
//  Redux-ReactiveSwift
//
//  Created by Petro Korienev on 1/1/18.
//

import Quick
import Nimble
import ReactiveSwift
import Redux_ReactiveSwift

class StoreBuilderSpec: QuickSpec {
    override func spec() {
        struct AppState: Defaultable { let some: String; static var defaultValue = AppState(some: "default")}
        enum AppEvent { case some }
        func appReducer(state: AppState, event: AppEvent) -> AppState { return state }
        
        describe("Core concepts") {
            it("should pass initialization with state") {
                let s = StoreBuilder<AppState, AppEvent, Store<AppState, AppEvent>>
                    .init(state: AppState(some: "s"))
                    .build()
                expect(s.value.some) == "s"
            }
            it("should pass defaultable initialization") {
                let s = StoreBuilder<AppState, AppEvent, Store<AppState, AppEvent>>()
                    .build()
                expect(s.value.some) == "default"
            }
            it("should correctly perform verbose build") {
                let s = StoreBuilder<AppState, AppEvent, Store<AppState, AppEvent>>()
                    .verboseBuild()
                expect(s.store.value.some) == "default"
                expect(s.middlewares.count) == 0
                expect(s.reducers.count) == 0
            }
            it("should build store with reducers") {
                let spy = CallSpy.makeCallSpy(f2: appReducer)
                let s = StoreBuilder<AppState, AppEvent, Store<AppState, AppEvent>>()
                    .reducer(spy.1)
                    .reducer(spy.1)
                    .reducer(spy.1)
                    .verboseBuild()
                s.store.consume(event: .some)
                expect(s.reducers.count) == 3
                expect(spy.0.callCount) == 3
            }
        }
        
        describe("DSL tests") {
            
        }
    }
}
