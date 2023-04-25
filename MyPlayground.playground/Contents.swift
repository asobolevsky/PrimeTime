import ComposableArchitechture
import Counter
import FavoritePrimes
import PlaygroundSupport
import SwiftUI

let favoritePrimesState = FavoritePrimesState(primes: [1, 3, 5, 7])
let favoritePrimesStore = Store(initialValue: favoritePrimesState, reducer: favoritePrimesReducer)
let favoritePrimesView = NavigationView {
    FavoritePrimesView(store: favoritePrimesStore)
}


let counterState = CounterViewState(
    count: 0,
    favoritePrimes: FavoritePrimesState(primes: []),
    nthPrime: nil,
    nthPrimeButtonDisabled: false
)
let counterStore = Store(initialValue: counterState, reducer: logging(counterViewReducer))
let counterView = CounterView(store: counterStore)

let rootView = counterView

PlaygroundPage.current.liveView = UIHostingController(
    rootView: rootView
        .frame(width: 375, height: 830)
)
