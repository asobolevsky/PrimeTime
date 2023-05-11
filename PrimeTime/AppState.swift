//
//  Models.swift
//  PrimeTime
//
//  Created by Aleksei Sobolevskii on 2023-04-20.
//

import CasePaths
import ComposableArchitechture
import CommonState
import Counter
import FavoritePrimes
import Foundation
import PrimeModal

// MARK: - State

struct AppState: Equatable {
    var count = 0
    var favoritePrimes = [1, 3, 5, 7]
    var loggedInUser: User? = nil
    var activityFeed: [Activity] = []
    var nthPrime: NthPrime? = nil
    var isNthPrimeRequestInFlight: Bool = false
    var isPrimeModalShown: Bool = false

    struct Activity: Equatable {
        var timestamp = Date()
        let type: ActivityType

        enum ActivityType: Equatable {
            case addedFavoritePrime(Int)
            case deletedFavoritePrime(Int)
        }
    }

    struct User: Equatable {
        let id: Int
        let name: String
        let bio: String
    }
}

extension AppState {
    var favoritePrimesState: FavoritePrimesState {
        get {
            FavoritePrimesState(primes: favoritePrimes, nthPrime: nthPrime)
        }
        set {
            (favoritePrimes, nthPrime) = (newValue.primes, newValue.nthPrime)
        }
    }

    var counterView: CounterFeatureState {
        get {
            CounterFeatureState(
                count: count,
                favoritePrimes: favoritePrimes,
                nthPrime: nthPrime,
                isNthPrimeRequestInFlight: isNthPrimeRequestInFlight,
                isPrimeModalShown: isPrimeModalShown
            )
        }
        set {
            self.count = newValue.count
            self.favoritePrimes = newValue.favoritePrimes
            self.nthPrime = newValue.nthPrime
            self.isNthPrimeRequestInFlight = newValue.isNthPrimeRequestInFlight
            self.isPrimeModalShown = newValue.isPrimeModalShown
        }
    }
}

// MARK: - Actions

enum AppAction: Equatable {
    case counterView(CounterFeatureAction)
    case favoritePrimes(FavoritePrimesAction)

    var counterView: CounterFeatureAction? {
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

// MARK: - Environment

struct AppEnvironment {
    var fileClient: FileClient
    var nthPrime: (Int) -> Effect<Int?>
}

extension AppEnvironment {
    static let live = AppEnvironment(fileClient: .live, nthPrime: Counter.fetchNthPrime)
    static let mock = AppEnvironment(fileClient: .mock, nthPrime: { _ in .sync { 17 } })
}

// MARK: - Reducers

func activityFeed(
    _ reducer: @escaping Reducer<AppState, AppAction, AppEnvironment>
) -> Reducer<AppState, AppAction, AppEnvironment> {
    return { state, action, environment in
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

        return reducer(&state, action, environment)
    }
}

let _appReducer: Reducer<AppState, AppAction, AppEnvironment> = combine(
    pullback(
        counterViewReducer,
        value: \.counterView,
        action: /AppAction.counterView,
        environment: { $0.nthPrime }
    ),
    pullback(
        favoritePrimesReducer,
        value: \.favoritePrimesState,
        action: /AppAction.favoritePrimes,
        environment: { ($0.fileClient, $0.nthPrime) }
    )
)

let appReducer = with(
    _appReducer,
//    compose(logging, activityFeed)
    activityFeed
)
