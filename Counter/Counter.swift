//
//  Counter.swift
//  Counter
//
//  Created by Aleksei Sobolevskii on 2023-04-20.
//

import CasePaths
import Combine
import CommonState
import ComposableArchitechture
import FavoritePrimes
import PrimeModal
import SwiftUI

// MARK: - Environment

public typealias CounterEnvironment = (Int) -> Effect<Int?>

// MARK: - State

typealias CounterState = (count: Int, nthPrime: NthPrime?, nthPrimeButtonDisabled: Bool)

public struct CounterViewState: Equatable {
    public var count: Int
    public var favoritePrimes: [Int]
    public var nthPrime: NthPrime?
    public var nthPrimeButtonDisabled: Bool

    public init(
        count: Int = 0,
        favoritePrimes: [Int] = [],
        nthPrime: NthPrime? = nil,
        nthPrimeButtonDisabled: Bool = false
    ) {
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

public enum CounterAction: Equatable {
    case increment
    case decrement
    case nthPrimeButtonTapped
    case nthPrimeResponse(n: Int, prime: Int?)
    case alertDismissButtonTapped
}

public enum CounterViewAction: Equatable {
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

private func counterReducer(
    state: inout CounterState,
    action: CounterAction,
    environment: CounterEnvironment
) -> [Effect<CounterAction>] {
    switch action {
    case .increment:
        state.count += 1
        return []

    case .decrement:
        state.count -= 1
        return []

    case .nthPrimeButtonTapped:
        state.nthPrimeButtonDisabled = true
        let n = state.count
        return [
            environment(state.count)
                .map { CounterAction.nthPrimeResponse(n: n, prime: $0) }
                .receive(on: DispatchQueue.main)
                .eraseToEffect()
        ]

    case let .nthPrimeResponse(n, prime):
        state.nthPrime = NthPrime(n: n, prime: prime)
        state.nthPrimeButtonDisabled = false
        return []

    case .alertDismissButtonTapped:
        state.nthPrime = nil
        return []
    }
}

public func fetchNthPrime(_ n: Int) -> Effect<Int?> {
    wolframAlpha(query: "prime \(n)").map { result in
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
    }
    .eraseToEffect()
}



public func offlineNthPrime(_ n: Int) -> Effect<Int?> {
    Future { callback in
        var nthPrime = 1
        var count = 0
        while count <= n {
            nthPrime += 1
            if isPrime(nthPrime) {
                count += 1
            }
        }
        callback(.success(nthPrime))
    }
    .eraseToEffect()
}

private func isPrime(_ p: Int) -> Bool {
    if p <= 1 { return false }
    if p <= 3 { return true }
    for i in 2...Int(sqrt(Double(p))) {
        if p % i == 0 { return false }
    }
    return true
}

public let counterViewReducer: Reducer<CounterViewState, CounterViewAction, CounterEnvironment> = combine(
    pullback(
        counterReducer,
        value: \.counter,
        action: /CounterViewAction.counter,
        environment: { $0 }
    ),
    pullback(
        primeModalReducer,
        value: \.primeModal,
        action: /CounterViewAction.primeModal,
        environment: { _ in () }
    )
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
                title: Text("The \(ordinal(nthPrime.n)) prime is \(nthPrime.prime ?? 0)"),
                dismissButton: .default(Text("OK")) { store.send(.counter(.alertDismissButtonTapped)) }
            )
        }
    }
}

extension Int: Identifiable {
    public var id: Int { self }
}
