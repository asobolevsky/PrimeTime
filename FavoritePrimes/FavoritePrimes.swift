//
//  FavoritePrimes.swift
//  FavoritePrimes
//
//  Created by Aleksei Sobolevskii on 2023-04-20.
//

import ComposableArchitechture
import Foundation
import SwiftUI

// MARK: - Models



// MARK: - Actions

public enum FavoritePrimesAction {
    case deleteFavoritePrimes(IndexSet)
    case updateFavoritePrimes([Int])

    case saveFavoritePrimes
    case loadFavoritePrimes
}

// MARK: - Reducers

private var favoritePrimesFileUrl: URL {
    let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    let documentsUrl = URL(fileURLWithPath: documentsPath)
    return documentsUrl.appendingPathComponent("favorite-primes.json")
}

public func favoritePrimesReducer(
    state: inout [Int],
    action: FavoritePrimesAction
) -> [Effect<FavoritePrimesAction>] {
    switch action {
    case let .deleteFavoritePrimes(indexSet):
        indexSet.forEach { state.remove(at: $0) }
        return []

    case let .updateFavoritePrimes(favoritePrimes):
        state = favoritePrimes
        return []

    case .saveFavoritePrimes:
        return [saveEffect(favoritePrimes: state)]

    case .loadFavoritePrimes:
        return [
            loadEffect()
                .compactMap { $0 }
                .eraseToEffect()
        ]
    }
}

private func saveEffect(favoritePrimes: [Int]) -> Effect<FavoritePrimesAction> {
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
            let favoritePrimes = try JSONDecoder().decode([Int].self, from: data)
            return .updateFavoritePrimes(favoritePrimes)
        } catch {
            print(error)
            return nil
        }
    }
}


// MARK: - Views

public struct FavoritePrimesView: View {
    @ObservedObject private var store: Store<[Int], FavoritePrimesAction>

    public init(store: Store<[Int], FavoritePrimesAction>) {
        self.store = store
    }

    public var body: some View {
        List {
            ForEach(store.value, id: \.self) { number in
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
