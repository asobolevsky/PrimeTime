//
//  ContentView.swift
//  PrimeTime
//
//  Created by Aleksei Sobolevskii on 2023-04-20.
//

import ComposableArchitechture
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
                                state: { ($0.count, $0.favoritePrimes) },
                                action: { $0 }
                            )
                    )
                ) {
                    Text("Counter Demo")
                }
                NavigationLink(
                    destination: FavoritePrimesView(
                        store: store
                            .view(
                                state: { $0.favoritePrimes },
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

struct CounterView: View {
    @ObservedObject var store: Store<CounterState, AppAction>

    @State private var isPrimeModalPresented = false
    @State private var nthPrime: Int?
    @State private var nthPrimeButtonDisabled = false

    var body: some View {
        VStack {
            HStack {
                Button("-") { store.send(.counter(.decrement)) }
                Text("\(store.state.count)")
                Button("+") { store.send(.counter(.increment)) }
            }
            Button("Is this prime?", action: { isPrimeModalPresented = true })
            Button("What is the \(ordinal(store.state.count)) prime?") {
                nthPrimeButtonDisabled = true
                nthPrime(store.state.count) { prime in
                    DispatchQueue.main.async {
                        self.nthPrime = prime
                        self.nthPrimeButtonDisabled = false
                    }
                }
            }
            .disabled(nthPrimeButtonDisabled)
        }
        .font(.title)
        .navigationTitle(Text("Counter Demo"))
        .sheet(isPresented: $isPrimeModalPresented) {
            PrimeCheckView(
                store: store
                    .view(
                        state: { $0 },
                        action: { .primeModal($0) }
                    )
            )
        }
        .alert("The \(ordinal(store.state.count)) prime is \(nthPrime ?? 0)", isPresented: .constant(nthPrime != nil)) {
            Button("OK") { nthPrime = nil }
        }
    }

    private func nthPrime(_ n: Int, callback: @escaping (Int?) -> Void) -> Void {
        wolframAlpha(query: "prime \(n)") { result in
            callback(
                result
                    .flatMap {
                        $0.queryresult
                            .pods
                            .first(where: { $0.primary == .some(true) })?
                            .subpods
                            .first?
                            .plaintext
                    }
                    .flatMap(Int.init)
            )
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(store: Store(initialState: AppState(), reducer: appReducer))
    }
}
