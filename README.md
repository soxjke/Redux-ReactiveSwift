![Support Ukraine](https://img.shields.io/badge/Support%20%F0%9F%87%BA%F0%9F%87%A6-Ukraine-yellowgreen?link=https://supportukrainenow.org/)

# IMPORTANT: SUPPORT UKRAINE NOW 🇺🇦

Please, spend few minutes reading through the website: 

https://supportukrainenow.org/

Your help can save lives today!


# Redux-ReactiveSwift

[![Redux-ReactiveSwift](https://github.com/soxjke/Redux-ReactiveSwift/blob/master/Redux-ReactiveSwift-logo.svg)](https://github.com/soxjke/Redux-ReactiveSwift)

[![CI Status](https://travis-ci.org/soxjke/Redux-ReactiveSwift.svg?branch=master)](https://travis-ci.org/soxjke/Redux-ReactiveSwift)
[![Code coverage status](https://img.shields.io/codecov/c/github/soxjke/Redux-ReactiveSwift.svg?style=flat)](http://codecov.io/github/soxjke/Redux-ReactiveSwift)
[![Version](https://img.shields.io/cocoapods/v/Redux-ReactiveSwift.svg?style=flat)](http://cocoapods.org/pods/Redux-ReactiveSwift)
[![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](http://cocoapods.org/pods/Redux-ReactiveSwift)
[![Platform](https://img.shields.io/cocoapods/p/Redux-ReactiveSwift.svg?style=flat)](http://cocoapods.org/pods/Redux-ReactiveSwift)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

This library focuses on predictable state container implementation inspired by [JS Redux](http://redux.js.org). It benefits from [ReactiveSwift](https://github.com/ReactiveCocoa/ReactiveSwift). Using functional reactive approach & predictable state containers one should be able to write more clean & testable code :)

## Example

The basic usage is pretty straightforward - one can create a store with `State` and reducer('s) of type `(State, Event) -> State`

```swift
import Redux_ReactiveSwift

class ViewModel {
    enum ButtonAction {
        case plus
        case minus
    }
    private(set) lazy var itemQuantityStore = Store<Int, ButtonAction>(state: 1, reducers: [self.itemQuantityReducer])
    private func itemQuantityReducer(state: Int, event: ButtonAction) -> Int {
        switch (event) {
            case .plus: return state + 1;
            case .minus: return state - 1;
        }
    }
}
```

Further, there can be benefit of binding data from `Store` using ReactiveSwift's `UnidirectionaBinding`:

```swift
class ViewController: UIViewController {
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var minusButton: UIButton!
    lazy var viewModel = ViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        quantityLabel.reactive.text <~ viewModel.itemQuantityStore.map(String.describing)
    }
}
```

To connect actions one can use ReactiveSwift's ```Action```:

```swift
extension ViewModel {
    func action(for buttonAction: ButtonAction) -> Action<(), (), NoError> {
        return Action {
            return SignalProducer<(), NoError> { [weak self] in
                self?.itemQuantityStore.consume(event: buttonAction)
            }
        }
    }
}

class ViewController {
...
    override func viewDidLoad() {
        super.viewDidLoad()
        quantityLabel.reactive.text <~ viewModel.itemQuantityStore.map(String.describing)
        plusButton.reactive.pressed = CocoaAction(viewModel.action(for: .plus))
        minusButton.reactive.pressed = CocoaAction(viewModel.action(for: .minus))
    }
}
```

State changing logic is completely in one place. Forever. If we'd like to have something more advanced we can benefit of reducers chain:

```swift
extension ClosedRange {
    func clamp(_ value : Bound) -> Bound {
        return self.lowerBound > value ? self.lowerBound
            : self.upperBound < value ? self.upperBound
            : value
    }
}

class ViewModel {
    private func itemQuantityClamper(state: Int, event: ButtonAction) -> Int {
        return (0...10).clamp(state)
    }
    private(set) lazy var itemQuantityStore = Store<Int, ButtonAction>(state: 1, reducers: [self.itemQuantityReducer, self.itemQuantityClamper]
}
```

or it can be done with a single reducer with benefit of some kind of functional ```applyMap```:

```swift
// This one looks ugly because tuple splatting was removed in Swift 4, thanks Chris Lattner!
func applyMap<R1, R2>(f2: @escaping (R1, R2) -> R1, mapper: @escaping (R1) -> R1) -> (R1, R2) -> R1 {
    return { (arg1, arg2) -> R1 in
        return mapper(f2(arg1, arg2))
    }
}
...
    private(set) lazy var itemQuantityStore = Store<Int, ButtonAction>(state: 1, reducers: [applyMap(f2: self.itemQuantityReducer, mapper: ClosedRange.clamp((0...10))]

```

Due to functional reactive spirit of solution you're limited only by your fantasy and Mr.Lattner's "enhancements" to Swift language. Some more cases of `Store` usage can be found in tests spec:

https://github.com/soxjke/Redux-ReactiveSwift/blob/master/Redux-ReactiveSwift/Tests/StoreSpec.swift

## Requirements

## Installation

Redux-ReactiveSwift is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Redux-ReactiveSwift'
```

Redux-ReactiveSwift is available through [Carthage](https://github.com/Carthage/Carthage). To install
it, simply add the following line to your Podfile:

```ruby
github "soxjke/Redux-ReactiveSwift"
```

## Author

Petro Korienev, soxjke@gmail.com

## License

Redux-ReactiveSwift is available under the MIT license. See the LICENSE file for more info.
