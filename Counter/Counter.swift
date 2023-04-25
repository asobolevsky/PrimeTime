//
//  Counter.swift
//  Counter
//
//  Created by Aleksei Sobolevskii on 2023-04-20.
//

import ComposableArchitechture
import PrimeModal
import SwiftUI

// MARK: - Actions

public enum CounterAction {
    case increment
    case decrement
}

public enum CounterViewAction {
    case counter(CounterAction)
    case primeModal(PrimeModalAction)

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
}

// MARK: - Reducers

func counterReducer(state: inout Int, action: CounterAction) -> [Effect<CounterAction>] {
    switch action {
    case .increment:
        state += 1
        return []

    case .decrement:
        state -= 1
        return []
    }
}

public let counterViewReducer: Reducer<CounterState, CounterViewAction> = combine(
    pullback(counterReducer(state: \CounterState.count, action: \CounterViewAction.counter)),
    pullback(primeModalReducer(state: \CounterState.favoritePrimes, action: \CounterViewAction.counter)),
)

// MARK: - Views

public struct CounterView: View {
    @ObservedObject private var store: Store<CounterState, CounterViewAction>

    @State private var isPrimeModalPresented = false
    @State private var nthPrime: Int?
    @State private var nthPrimeButtonDisabled = false

    public init(store: Store<CounterState, CounterViewAction>) {
        self.store = store
    }

    public var body: some View {
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
