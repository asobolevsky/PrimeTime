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

typealias CounterState = (count: Int, nthPrime: NthPrime?, isNthPrimeRequestInFlight: Bool, isPrimeModalShown: Bool)

public struct CounterFeatureState: Equatable {
    public var count: Int
    public var favoritePrimes: [Int]
    public var nthPrime: NthPrime?
    public var isNthPrimeRequestInFlight: Bool
    public var isPrimeModalShown: Bool

    public init(
        count: Int = 0,
        favoritePrimes: [Int] = [],
        nthPrime: NthPrime? = nil,
        isNthPrimeRequestInFlight: Bool = false,
        isPrimeModalShown: Bool = false
    ) {
        self.count = count
        self.favoritePrimes = favoritePrimes
        self.nthPrime = nthPrime
        self.isNthPrimeRequestInFlight = isNthPrimeRequestInFlight
        self.isPrimeModalShown = isPrimeModalShown
    }

    var counter: CounterState {
        get { (count, nthPrime, isNthPrimeRequestInFlight, isPrimeModalShown) }
        set { (count, nthPrime, isNthPrimeRequestInFlight, isPrimeModalShown) = newValue }
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
    case isPrimeButtonTapped
    case primeModalDismissed
    case nthPrimeButtonTapped
    case nthPrimeResponse(n: Int, prime: Int?)
    case alertDismissButtonTapped
}

public enum CounterFeatureAction: Equatable {
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

    case .isPrimeButtonTapped:
      state.isPrimeModalShown = true
      return []

    case .primeModalDismissed:
      state.isPrimeModalShown = false
      return []

    case .nthPrimeButtonTapped:
        state.isNthPrimeRequestInFlight = true
        let n = state.count
        return [
            environment(state.count)
                .map { CounterAction.nthPrimeResponse(n: n, prime: $0) }
                .receive(on: DispatchQueue.main)
                .eraseToEffect()
        ]

    case let .nthPrimeResponse(n, prime):
        state.nthPrime = NthPrime(n: n, prime: prime)
        state.isNthPrimeRequestInFlight = false
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

public let counterViewReducer: Reducer<CounterFeatureState, CounterFeatureAction, CounterEnvironment> = combine(
    pullback(
        counterReducer,
        value: \.counter,
        action: /CounterFeatureAction.counter,
        environment: { $0 }
    ),
    pullback(
        primeModalReducer,
        value: \.primeModal,
        action: /CounterFeatureAction.primeModal,
        environment: { _ in () }
    )
)

// MARK: - Views

public struct CounterView: View {
    struct ViewState: Equatable {
        let count: Int
        let nthPrimeButtonDisabled: Bool
        let isPrimeModalShown: Bool
        let nthPrime: NthPrime?
    }

    private let store: Store<CounterFeatureState, CounterFeatureAction>
    @ObservedObject private var viewStore: ViewStore<ViewState>

    public init(store: Store<CounterFeatureState, CounterFeatureAction>) {
        print("CounterView.init")
        self.store = store
        self.viewStore = store
            .scope(value: ViewState.init(counterFeatureState:), action: { $0 })
            .view
    }

    public var body: some View {
        print("CounterView.body")
        return VStack {
            HStack {
                Button("-") { store.send(.counter(.decrement)) }
                Text("\(viewStore.value.count)")
                Button("+") { store.send(.counter(.increment)) }
            }
            Button("Is this prime?", action: { store.send(.counter(.isPrimeButtonTapped)) })
            Button("What is the \(ordinal(viewStore.value.count)) prime?") {
                store.send(.counter(.nthPrimeButtonTapped))
            }
            .disabled(viewStore.value.nthPrimeButtonDisabled)
        }
        .font(.title)
        .navigationTitle(Text("Counter Demo"))
        .sheet(
            isPresented: .constant(viewStore.value.isPrimeModalShown),
            onDismiss: { store.send(.counter(.primeModalDismissed)) }
        ) {
            PrimeCheckView(
                store: store
                    .scope(
                        value: { $0.primeModal },
                        action: { .primeModal($0) }
                    )
            )
        }
        .alert(item: .constant(viewStore.value.nthPrime)) { nthPrime in
            Alert(
                title: Text("The \(ordinal(nthPrime.n)) prime is \(nthPrime.prime ?? 0)"),
                dismissButton: .default(Text("OK")) { store.send(.counter(.alertDismissButtonTapped)) }
            )
        }
    }
}

extension CounterView.ViewState {
    init(counterFeatureState: CounterFeatureState) {
        self.init(
            count: counterFeatureState.count,
            nthPrimeButtonDisabled: counterFeatureState.isNthPrimeRequestInFlight,
            isPrimeModalShown: counterFeatureState.isPrimeModalShown,
            nthPrime: counterFeatureState.nthPrime
        )
    }
}

extension Int: Identifiable {
    public var id: Int { self }
}
