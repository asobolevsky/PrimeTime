import ComposableArchitechture
@testable import Counter
import PlaygroundSupport
import SwiftUI


//import FavoritePrimes
//import Combine
//import SafariServices
//import CommonState
//import CasePaths

// MARK: - FavoritePrimes

//let fileClient = FileClient(
//    load: { _ in
//            .sync {
//                try! JSONEncoder().encode(Array(1...10))
//            }
//    },
//    save: { _, _ in .fireAndForget {} }
//)
//let environment: FavoritePrimesEnvironment = (
//    fileClient: fileClient,
//    nthPrime: { _ in .sync { nil } }
//)
//
//let favoritePrimesState = FavoritePrimesState(primes: [1, 3, 5, 7])
//let favoritePrimesStore = Store(
//    initialValue: favoritePrimesState,
//    environment: environment,
//    reducer: favoritePrimesReducer
//)

// MARK: - Counter

let state = CounterFeatureState()

let store = Store(
    initialValue: state,
    environment: { _ in .sync { nil } },
    reducer: counterViewReducer
)

let rootView = NavigationView {
    CounterView(store: store)
}

PlaygroundPage.current.liveView = UIHostingController(
    rootView: rootView
        .frame(width: 375, height: 830)
)
