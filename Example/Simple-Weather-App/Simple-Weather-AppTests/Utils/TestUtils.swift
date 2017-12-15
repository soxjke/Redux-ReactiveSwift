//
//  TestUtils.swift
//  Simple-Weather-AppTests
//
//  Created by Petro Korienev on 10/26/17.
//  Copyright © 2017 Sigma Software. All rights reserved.
//

import Foundation

extension Bundle {
    static var test: Bundle {
        return (self.allBundles.first { $0.bundlePath.contains(".xctest") })!
    }
}
