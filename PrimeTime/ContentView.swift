//
//  ContentView.swift
//  PrimeTime
//
//  Created by Aleksei Sobolevskii on 2023-04-20.
//

import ComposableArchitechture
import Counter
import FavoritePrimes
import PrimeModal
import SwiftUI

struct ContentView: View {
    @ObservedObject var store: Store<AppState, AppAction>

    var body: some View {
        NavigationView {
            List {
                NavigationLink(
                    destination: CounterView(
                        store: store
                            .view(
                                value: { $0.counterView },
                                action: { .counterView($0) }
                            )
                    )
                ) {
                    Text("Counter Demo")
                }
                NavigationLink(
                    destination: FavoritePrimesView(
                        store: store
                            .view(
                                value: { $0.favoritePrimes },
                                action: { .favoritePrimes($0) }
                            )
                    )
                ) {
                    Text("Favorite Primes")
                }
            }
            .navigationTitle(Text("State Management"))
        }
        .navigationViewStyle(.stack)
        .environmentObject(store)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(store: Store(initialValue: AppState(), reducer: appReducer))
    }
}
