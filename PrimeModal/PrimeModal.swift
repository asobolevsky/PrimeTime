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

public typealias PrimeModalState = (count: Int, favoritePrimes: [Int])

// MARK: - Actions

public enum PrimeModalAction: Equatable {
    case saveFavoritePrime
    case deleteFavoritePrime
}

// MARK: - Reducers

public func primeModalReducer(
    state: inout PrimeModalState,
    action: PrimeModalAction,
    environment: Void
) -> [Effect<PrimeModalAction>] {
    switch action {
    case .saveFavoritePrime:
        state.favoritePrimes.append(state.count)
        return []

    case .deleteFavoritePrime:
        state.favoritePrimes.removeAll { $0 == state.count }
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

                if store.value.favoritePrimes.contains(store.value.count) {
                    Button {
                        store.send(.deleteFavoritePrime)
                    } label: {
                        Text("Delete from favorite primes")
                    }
                } else {
                    Button {
                        store.send(.saveFavoritePrime)
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
