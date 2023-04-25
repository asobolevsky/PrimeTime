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

// MARK: - Actions

enum AppAction {
    case counter(CounterAction)
    case primeModal(PrimeModalAction)
    case favoritePrimes(FavoritePrimesAction)

    var counter: CounterAction? {
        get {
            guard case let .counter(value) = self else { return nil }
            return value
        }
        set {
            guard case .counter = self, let newValue = newValue else { return }
            self = .counter(newValue)
        }
    }

    var primeModal: PrimeModalAction? {
        get {
            guard case let .primeModal(value) = self else { return nil }
            return value
        }
        set {
            guard case .primeModal = self, let newValue = newValue else { return }
            self = .primeModal(newValue)
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

func logging<State, Action>(
    _ reducer: @escaping Reducer<State, Action>
) -> Reducer<State, Action> {
    return { state, action in 
        let effect = reducer(&state, action)
        let newState = state

        return {
            print("Action: \(action)")
            print("Value:")
            dump(newState)
            print("---")
            effect()
        }
    }
}

let _appReducer: Reducer<AppState, AppAction> = combine(
    pullback(counterReducer, value: \.count, action: \.counter),
    pullback(primeModalReducer, value: \.favoritePrimes, action: \.primeModal),
    pullback(favoritePrimesReducer, value: \.favoritePrimes, action: \.favoritePrimes)
)

let appReducer = with(
    _appReducer,
    compose(logging, activityFeed)
)
