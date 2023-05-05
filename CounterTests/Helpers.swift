//
//  Helpers.swift
//  CounterTests
//
//  Created by Aleksei Sobolevskii on 2023-05-01.
//

import Foundation

protocol Modifiable {
    func modified<Value>(_ what: WritableKeyPath<Self, Value>, _ value: Value) -> Self
}

extension Modifiable {
    func modified<Value>(_ what: WritableKeyPath<Self, Value>, _ value: Value) -> Self {
        var state = self
        state[keyPath: what] = value
        return state
    }
}
