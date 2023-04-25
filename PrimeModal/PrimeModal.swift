//
//  PrimeModal.swift
//  PrimeModal
//
//  Created by Aleksei Sobolevskii on 2023-04-20.
//

import ComposableArchitechture
import FavoritePrimes
import Foundation
import SwiftUI

// MARK: -

public typealias CounterState = (count: Int, favoritePrimes: FavoritePrimesState)

// MARK: - Actions

public enum PrimeModalAction {
    case saveFavoritePrime(Int)
    case removeFavoritePrime(Int)
}

// MARK: - Reducers

public func primeModalReducer(state: inout FavoritePrimesState, action: PrimeModalAction) -> Effect {
    switch action {
    case .saveFavoritePrime(let prime):
        state.primes.insert(prime)
        return {}

    case .removeFavoritePrime(let prime):
        state.primes.remove(prime)
        return {}
    }
}

// MARK: - Views

public struct PrimeCheckView: View {
    @ObservedObject var store: Store<CounterState, PrimeModalAction>

    public init(store: Store<CounterState, PrimeModalAction>) {
        self.store = store
    }

    public var body: some View {
        VStack {
            if isPrime(store.state.count) {
                Text("\(store.state.count) is prime 🎉")

                if store.state.favoritePrimes.primes.contains(store.state.count) {
                    Button {
                        store.send(.removeFavoritePrime(store.state.count))
                    } label: {
                        Text("Remove from favorite primes")
                    }
                } else {
                    Button {
                        store.send(.saveFavoritePrime(store.state.count))
                    } label: {
                        Text("Save to favorite primes")
                    }
                }
            } else {
                Text("\(store.state.count) is not prime :(")
            }
        }
    }
}

private func isPrime(_ p: Int) -> Bool {
    if p <= 1 { return false }
    if p <= 3 { return true }
    for i in 2...Int(sqrt(Double(p))) {
        if p % i == 0 { return false }
    }
    return true
}
