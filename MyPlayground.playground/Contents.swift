import ComposableArchitechture
import Counter
@testable import FavoritePrimes
import PlaygroundSupport
import SwiftUI
import Combine
import SafariServices

// MARK: -

let fileClient = FileClient(
    load: { _ in
            .sync {
                try! JSONEncoder().encode(Array(1...10))
            }
    },
    save: { _, _ in .fireAndForget {} }
)
let environment = FavoritePrimesEnvironment(fileClient: fileClient)

let favoritePrimesState = [1, 3, 5, 7]
let favoritePrimesStore = Store(
    initialValue: favoritePrimesState,
    environment: environment,
    reducer: favoritePrimesReducer
)
let favoritePrimesView = NavigationView {
    FavoritePrimesView(store: favoritePrimesStore)
}

PlaygroundPage.current.liveView = UIHostingController(
    rootView: favoritePrimesView
        .frame(width: 375, height: 830)
)
