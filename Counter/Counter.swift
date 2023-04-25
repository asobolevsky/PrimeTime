//
//  Counter.swift
//  Counter
//
//  Created by Aleksei Sobolevskii on 2023-04-20.
//

import ComposableArchitechture

// MARK: - Actions

public enum CounterAction {
    case increment
    case decrement
}

// MARK: - Reducers

public func counterReducer(state: inout Int, action: CounterAction) -> Effect {
    switch action {
    case .increment:
        state += 1
        return {}

    case .decrement:
        state -= 1
        return {}
    }
}
