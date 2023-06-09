//
//  FavoritePrimes.swift
//  FavoritePrimes
//
//  Created by Aleksei Sobolevskii on 2023-04-20.
//

import Combine
import CommonState
import ComposableArchitechture
import Foundation
import SwiftUI

// MARK: - Environment

public typealias FavoritePrimesEnvironment = (
    fileClient: FileClient,
    nthPrime: (Int) -> Effect<Int?>
)

public struct FileClient {
    var load: (String) -> Effect<Data?>
    var save: (String, Data) -> Effect<Never>
}

public extension FileClient {
    static let live = FileClient(
        load: { fileName in
                .sync {
                    do {
                        let data = try Data(contentsOf: documentFileUrl(with: fileName))
                        return data
                    } catch {
                        print(error)
                        return nil
                    }
                }
        },
        save: { fileName, data in
                .fireAndForget {
                    do {
                        try data.write(to: documentFileUrl(with: fileName))
                    } catch {
                        print(error)
                    }
                }
        }
    )
}

//#if DEBUG
public extension FileClient {
    static let mock = FileClient(
        load: { _ in
            Effect<Data?>.sync {
                try! JSONEncoder().encode([2, 3, 5])
            }
        },
        save: { _, _ in .fireAndForget {} }
    )
}
//#endif

// MARK: - State

public struct FavoritePrimesState: Equatable {
    public var primes: [Int]
    public var nthPrime: NthPrime?

    public init(primes: [Int], nthPrime: NthPrime? = nil) {
        self.primes = primes
        self.nthPrime = nthPrime
    }
}

// MARK: - Actions

public enum FavoritePrimesAction: Equatable {
    case deleteFavoritePrimes(IndexSet)
    case updateFavoritePrimes([Int])

    case favoritePrimeTapped(Int)
    case nthPrimeResponse(n: Int, prime: Int?)
    case alertDismissButtonTapped

    case saveFavoritePrimes
    case loadFavoritePrimes
}

// MARK: - Reducers

private func documentFileUrl(with fileName: String) -> URL {
    let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    let documentsUrl = URL(fileURLWithPath: documentsPath)
    return documentsUrl.appendingPathComponent(fileName)
}

public typealias FavoritePrimesReducer = Reducer<FavoritePrimesState, FavoritePrimesAction, FavoritePrimesEnvironment>
public let favoritePrimesReducer = FavoritePrimesReducer { state, action, environment in
    switch action {
    case let .deleteFavoritePrimes(indexSet):
        indexSet.forEach { state.primes.remove(at: $0) }
        return []

    case let .updateFavoritePrimes(primes):
        state.primes = primes
        return []

    case let .favoritePrimeTapped(n):
        return [
            environment.nthPrime(n)
                .map { FavoritePrimesAction.nthPrimeResponse(n: n, prime: $0) }
                .receive(on: DispatchQueue.main)
                .eraseToEffect()
        ]

    case let .nthPrimeResponse(n, prime):
        state.nthPrime = NthPrime(n: n, prime: prime)
        return []

    case .alertDismissButtonTapped:
        state.nthPrime = nil
        return []

    case .saveFavoritePrimes:
        return [
            environment.fileClient
                .save(
                    "favorite-primes.json",
                    try! JSONEncoder().encode(state.primes)
                )
                .fireAndForget()
        ]

    case .loadFavoritePrimes:
        return [
            environment.fileClient
                .load("favorite-primes.json")
                .compactMap {
                    $0
                }
                .decode(type: [Int].self, decoder: JSONDecoder())
                .catch { error in
                    Empty(completeImmediately: true)
                }
                .map(FavoritePrimesAction.updateFavoritePrimes)
                .eraseToEffect()
        ]
    }
}


// MARK: - Views

public struct FavoritePrimesView: View {
    private let store: Store<FavoritePrimesState, FavoritePrimesAction>
    @ObservedObject var viewStore: ViewStore<FavoritePrimesState, FavoritePrimesAction>

    public init(store: Store<FavoritePrimesState, FavoritePrimesAction>) {
        self.store = store
        self.viewStore = store.view
    }

    public var body: some View {
        return List {
            ForEach(viewStore.primes, id: \.self) { number in
                Button("\(number)") {
                    viewStore.send(.favoritePrimeTapped(number))
                }
            }
            .onDelete { indexSet in
                viewStore.send(.deleteFavoritePrimes(indexSet))
            }
        }
        .navigationTitle("Favorite Primes")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    Button("Load") { viewStore.send(.loadFavoritePrimes) }
                    Button("Save") { viewStore.send(.saveFavoritePrimes) }
                }
            }
        }
        .alert(item: viewStore.binding(get: \.nthPrime, send: .alertDismissButtonTapped)) { nthPrime in
            Alert(title: Text("The \(ordinal(nthPrime.n)) prime is \(nthPrime.prime ?? 0)"))
        }
    }
}
