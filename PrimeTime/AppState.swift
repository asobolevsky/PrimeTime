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
    var favoritePrimes = [1, 3, 5, 7]
    var loggedInUser: User? = nil
    var activityFeed: [Activity] = []
    var nthPrime: NthPrime? = nil
    var nthPrimeButtonDisabled: Bool = false

    struct Activity {
        var timestamp = Date()
        let type: ActivityType

        enum ActivityType {
            case addedFavoritePrime(Int)
            case deletedFavoritePrime(Int)
        }
    }

    struct User {
        let id: Int
        let name: String
        let bio: String
    }
}

extension AppState {
    var counterView: CounterViewState {
        get {
            CounterViewState(
                count: count,
                favoritePrimes: favoritePrimes,
                nthPrime: nthPrime,
                nthPrimeButtonDisabled: nthPrimeButtonDisabled
            )
        }
        set {
            self.count = newValue.count
            self.favoritePrimes = newValue.favoritePrimes
            self.nthPrime = newValue.nthPrime
            self.nthPrimeButtonDisabled = newValue.nthPrimeButtonDisabled
        }
    }
}

// MARK: - Actions

enum AppAction {
    case counterView(CounterViewAction)
    case favoritePrimes(FavoritePrimesAction)

    var counterView: CounterViewAction? {
        get {
            guard case let .counterView(value) = self else { return nil }
            return value
        }
        set {
            guard case .counterView = self, let newValue = newValue else { return }
            self = .counterView(newValue)
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
        case .counterView(.primeModal(.deleteFavoritePrime)):
            state.activityFeed.append(.init(type: .deletedFavoritePrime(state.count)))

        case .counterView(.primeModal(.saveFavoritePrime)):
            state.activityFeed.append(.init(type: .addedFavoritePrime(state.count)))

        case let .favoritePrimes(.deleteFavoritePrimes(indexSet)):
            for index in indexSet {
                state.activityFeed.append(.init(type: .deletedFavoritePrime(state.favoritePrimes[index])))
            }

        default: break
        }

        return reducer(&state, action)
    }
}

let _appReducer: Reducer<AppState, AppAction> = combine(
    pullback(counterViewReducer, value: \.counterView, action: \.counterView),
    pullback(favoritePrimesReducer, value: \.favoritePrimes, action: \.favoritePrimes)
)

let appReducer = with(
    _appReducer,
    compose(logging, activityFeed)
)
