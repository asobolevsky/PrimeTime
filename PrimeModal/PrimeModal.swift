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
    struct ViewState: Equatable {
        let count: Int
        let isFavorite: Bool
    }

    private let store: Store<PrimeModalState, PrimeModalAction>
    @ObservedObject var viewStore: ViewStore<ViewState, PrimeModalAction>

    public init(store: Store<PrimeModalState, PrimeModalAction>) {
        self.store = store
        self.viewStore = store
            .scope(value: ViewState.init(primeModalState:), action: { $0 })
            .view
    }

    public var body: some View {
        return VStack {
            if isPrime(viewStore.value.count) {
                Text("\(viewStore.value.count) is prime 🎉")

                if viewStore.value.isFavorite {
                    Button {
                        viewStore.send(.deleteFavoritePrime)
                    } label: {
                        Text("Delete from favorite primes")
                    }
                } else {
                    Button {
                        viewStore.send(.saveFavoritePrime)
                    } label: {
                        Text("Save to favorite primes")
                    }
                }
            } else {
                Text("\(viewStore.value.count) is not prime :(")
            }
        }
    }
}

extension PrimeCheckView.ViewState {
    init(primeModalState: PrimeModalState) {
        let isFavorite = primeModalState.favoritePrimes.contains(primeModalState.count)
        self.init(
            count: primeModalState.count,
            isFavorite: isFavorite
        )
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
