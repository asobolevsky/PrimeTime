//
//  Models.swift
//  PrimeTime
//
//  Created by Aleksei Sobolevskii on 2023-04-20.
//

import ComposableArchitechture
import Counter
import FavoritePrimes
import Foundation
import PrimeModal

// MARK: - State

struct AppState {
    var count = 0
    var favoritePrimes: FavoritePrimesState = FavoritePrimesState(primes: [1, 3, 5, 7])
    var activityFeed: [Activity] = []
    var user: User?

    struct User {
        let id: Int
        let name: String
        let email: String
    }

    struct Activity {
        var timestamp = Date()
        let type: ActivityType

        enum ActivityType {
            case addedFavoritePrime(Int)
            case removedFavoritePrime(Int)
        }
    }
}

extension AppState {
    var counter: CounterViewState {
        get { CounterViewState() }
        set {}
    }
}

// MARK: - Actions

enum AppAction {
    case counter(CounterViewAction)
    case favoritePrimes(FavoritePrimesAction)

    var counter: CounterViewAction? {
        get {
            guard case let .counter(value) = self else { return nil }
            return value
        }
        set {
            guard case .counter = self, let newValue = newValue else { return }
            self = .counter(newValue)
        }
    }

    var favoritePrimes: FavoritePrimesAction? {
        get {
            guard case let .favoritePrimes(value) = self else { return nil }
            return value
        }
        set {
            guard case .favoritePrimes = self, let newValue = newValue else { return }
            self = .favoritePrimes(newValue)
        }
    }
}

// MARK: - Reducers

func activityFeed(
    _ reducer: @escaping Reducer<AppState, AppAction>
) -> Reducer<AppState, AppAction> {
    return { state, action in
        switch action {
        case let .primeModal(.removeFavoritePrime(prime)):
            state.activityFeed.append(.init(type: .removedFavoritePrime(prime)))

        case let .primeModal(.saveFavoritePrime(prime)):
            state.activityFeed.append(.init(type: .addedFavoritePrime(prime)))

        default: break
        }

        let effect = reducer(&state, action)
        return effect
    }
}

let _appReducer: Reducer<AppState, AppAction> = combine(
    pullback(counterViewReducer, value: \.counter, action: \.counter),
    pullback(favoritePrimesReducer, value: \.favoritePrimes, action: \.favoritePrimes)
)

let appReducer = with(
    _appReducer,
    compose(logging, activityFeed)
)
