import ComposableArchitechture
import FavoritePrimes
import PlaygroundSupport
import SwiftUI

let state = FavoritePrimesState(primes: [1, 3, 5, 7])
let rootView = FavoritePrimesView(
    store: Store(initialState: state, reducer: favoritePrimesReducer)
)

PlaygroundPage.current.liveView = UIHostingController(rootView: rootView)
