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

public typealias PrimeModalState = (count: Int, favoritePrimes: FavoritePrimesState)

// MARK: - Actions

public enum PrimeModalAction {
    case saveFavoritePrime(Int)
    case removeFavoritePrime(Int)
}

// MARK: - Reducers

public func primeModalReducer(state: inout PrimeModalState, action: PrimeModalAction) -> [Effect<PrimeModalAction>] {
    switch action {
    case .saveFavoritePrime(let prime):
        state.favoritePrimes.primes.insert(prime)
        return []

    case .removeFavoritePrime(let prime):
        state.favoritePrimes.primes.remove(prime)
        return []
    }
}

// MARK: - Views

public struct PrimeCheckView: View {
    @ObservedObject var store: Store<PrimeModalState, PrimeModalAction>

    public init(store: Store<PrimeModalState, PrimeModalAction>) {
        self.store = store
    }

    public var body: some View {
        VStack {
            if isPrime(store.value.count) {
                Text("\(store.value.count) is prime 🎉")

                if store.value.favoritePrimes.primes.contains(store.value.count) {
                    Button {
                        store.send(.removeFavoritePrime(store.value.count))
                    } label: {
                        Text("Remove from favorite primes")
                    }
                } else {
                    Button {
                        store.send(.saveFavoritePrime(store.value.count))
                    } label: {
                        Text("Save to favorite primes")
                    }
                }
            } else {
                Text("\(store.value.count) is not prime :(")
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
