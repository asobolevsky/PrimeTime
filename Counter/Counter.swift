//
//  Counter.swift
//  Counter
//
//  Created by Aleksei Sobolevskii on 2023-04-20.
//

import ComposableArchitechture
import FavoritePrimes
import PrimeModal
import SwiftUI

// MARK: - State

typealias CounterState = (count: Int, nthPrime: NthPrime?, nthPrimeButtonDisabled: Bool)

public struct NthPrime: Identifiable {
    let prime: Int
    public var id: Int { self.prime }
}

public struct CounterViewState {
    public var count: Int
    public var favoritePrimes: FavoritePrimesState
    public var nthPrime: NthPrime?
    public var nthPrimeButtonDisabled: Bool

    public init(count: Int, favoritePrimes: FavoritePrimesState, nthPrime: NthPrime?, nthPrimeButtonDisabled: Bool) {
        self.count = count
        self.favoritePrimes = favoritePrimes
        self.nthPrime = nthPrime
        self.nthPrimeButtonDisabled = nthPrimeButtonDisabled
    }

    var counter: CounterState {
        get { (count, nthPrime, nthPrimeButtonDisabled) }
        set { (count, nthPrime, nthPrimeButtonDisabled) = newValue }
    }

    var primeModal: PrimeModalState {
        get { (count, favoritePrimes) }
        set { (count, favoritePrimes) = newValue }
    }
}

// MARK: - Actions

public enum CounterAction {
    case increment
    case decrement
    case nthPrimeButtonTapped
    case nthPrimeResponse(NthPrime?)
    case alertDismissButtonTapped
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

private func counterReducer(state: inout CounterState, action: CounterAction) -> [Effect<CounterAction>] {
    switch action {
    case .increment:
        state.count += 1
        return []

    case .decrement:
        state.count -= 1
        return []

    case .nthPrimeButtonTapped:
        state.nthPrimeButtonDisabled = true
        let count = state.count
        return [{ callback in
            fetchNthPrime(count) { response in
                let prime = response != nil ? NthPrime(prime: response!) : nil
                DispatchQueue.main.async {
                    callback(.nthPrimeResponse(prime))
                }
            }
        }]

    case let .nthPrimeResponse(response):
        state.nthPrime = response
        state.nthPrimeButtonDisabled = false
        return []

    case .alertDismissButtonTapped:
        state.nthPrime = nil
        return []

    }
}

private func fetchNthPrime(_ n: Int, callback: @escaping (Int?) -> Void) -> Void {
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

public let counterViewReducer = combine(
    pullback(counterReducer, value: \CounterViewState.counter, action: \CounterViewAction.counter),
    pullback(primeModalReducer, value: \.primeModal, action: \.primeModal)
)

// MARK: - Views

public struct CounterView: View {
    @ObservedObject private var store: Store<CounterViewState, CounterViewAction>

    @State private var isPrimeModalPresented = false

    public init(store: Store<CounterViewState, CounterViewAction>) {
        self.store = store
    }

    public var body: some View {
        VStack {
            HStack {
                Button("-") { store.send(.counter(.decrement)) }
                Text("\(store.value.count)")
                Button("+") { store.send(.counter(.increment)) }
            }
            Button("Is this prime?", action: { isPrimeModalPresented = true })
            Button("What is the \(ordinal(store.value.count)) prime?") {
                store.send(.counter(.nthPrimeButtonTapped))
            }
            .disabled(store.value.nthPrimeButtonDisabled)
        }
        .font(.title)
        .navigationTitle(Text("Counter Demo"))
        .sheet(isPresented: $isPrimeModalPresented) {
            PrimeCheckView(
                store: store
                    .view(
                        value: { $0.primeModal },
                        action: { .primeModal($0) }
                    )
            )
        }
        .alert(item: .constant(store.value.nthPrime)) { nthPrime in
            Alert(
                title: Text("The \(ordinal(store.value.count)) prime is \(nthPrime.prime)"),
                dismissButton: .default(Text("OK")) { store.send(.counter(.alertDismissButtonTapped)) }
            )
        }
    }
}
