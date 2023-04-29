//
//  FavoritePrimes.swift
//  FavoritePrimes
//
//  Created by Aleksei Sobolevskii on 2023-04-20.
//

import ComposableArchitechture
import Foundation
import SwiftUI

// MARK: - Model

public struct FavoritePrimesState: Codable {
    public var primes: Set<Int>

    public init(primes: Set<Int>) {
        self.primes = primes
    }
}

public extension FavoritePrimesState {
    var sortedPrimes: [Int] {
        Array(primes).sorted()
    }
}

// MAKR: - Actions

public enum FavoritePrimesAction {
    case deleteFavoritePrimes(IndexSet)
    case updateFavoritePrimes(Set<Int>)

    case saveFavoritePrimes
    case loadFavoritePrimes
}

// MAKR: - Reducers

private var favoritePrimesFileUrl: URL {
    let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    let documentsUrl = URL(fileURLWithPath: documentsPath)
    return documentsUrl.appendingPathComponent("favorite-primes.json")
}

public func favoritePrimesReducer(
    state: inout FavoritePrimesState,
    action: FavoritePrimesAction
) -> [Effect<FavoritePrimesAction>] {
    switch action {
    case let .deleteFavoritePrimes(indexSet):
        for index in indexSet {
            let prime = state.sortedPrimes[index]
            state.primes.remove(prime)
        }
        return []

    case let .updateFavoritePrimes(favoritePrimes):
        state.primes = favoritePrimes
        return []

    case .saveFavoritePrimes:
        return [saveEffect(favoritePrimes: state.primes)]

    case .loadFavoritePrimes:
        return [
            loadEffect()
                .compactMap { $0 }
                .eraseToEffect()
        ]
    }
}

private func saveEffect(favoritePrimes: Set<Int>) -> Effect<FavoritePrimesAction> {
    Effect.fireAndForget {
        do {
            let data = try JSONEncoder().encode(favoritePrimes)
            try data.write(to: favoritePrimesFileUrl)
        } catch {
            print(error)
        }
    }
}

private func loadEffect() -> Effect<FavoritePrimesAction?> {
    Effect.sync {
        do {
            let data = try Data(contentsOf: favoritePrimesFileUrl)
            let favoritePrimes = try JSONDecoder().decode(Set<Int>.self, from: data)
            return .updateFavoritePrimes(favoritePrimes)
        } catch {
            print(error)
            return nil
        }
    }
}


// MARK: - Views

public struct FavoritePrimesView: View {
    @ObservedObject private var store: Store<FavoritePrimesState, FavoritePrimesAction>

    public init(store: Store<FavoritePrimesState, FavoritePrimesAction>) {
        self.store = store
    }

    public var body: some View {
        List {
            ForEach(store.value.sortedPrimes, id: \.self) { number in
                Text("\(number)")
            }
            .onDelete { indexSet in
                store.send(.deleteFavoritePrimes(indexSet))
            }
        }
        .navigationTitle("Favorite Primes")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    Button("Load") { store.send(.loadFavoritePrimes) }
                    Button("Save") { store.send(.saveFavoritePrimes) }
                }
            }
        }
    }
}
