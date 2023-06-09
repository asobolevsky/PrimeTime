//
//  CounterTests.swift
//  CounterTests
//
//  Created by Aleksei Sobolevskii on 2023-04-20.
//

import XCTest
@testable import Counter
import CommonState
import FavoritePrimes
import ComposableArchitechtureTestUtils
import Combine

final class CounterTests: XCTestCase {

    func testCounterIncrement() {
        assert(
            initialValue: CounterFeatureState(count: 2),
            reducer: counterViewReducer,
            environment: { _ in .sync { nil } },
            steps: [
                Step(.send, .counter(.increment), { $0.count = 3 }),
                Step(.send, .counter(.increment), { $0.count = 4 }),
            ]
        )
    }

    func testCounterDecrement() {
        assert(
            initialValue: CounterFeatureState(count: 3),
            reducer: counterViewReducer,
            environment: { _ in .sync { 17 } },
            steps: [
                Step(.send, .counter(.decrement), { $0.count = 2 }),
                Step(.send, .counter(.decrement), { $0.count = 1 }),
            ]
        )
    }

    func testNthPrimeButtonHappyFlow() {
        assert(
            initialValue: CounterFeatureState(count: 4, nthPrime: nil, isNthPrimeRequestInFlight: false),
            reducer: counterViewReducer,
            environment: { _ in .sync { 17 } },
            steps: [
                Step(.send, .counter(.requestNthPrime), { $0.isNthPrimeRequestInFlight = true }),
                Step(.receive, .counter(.nthPrimeResponse(n: 4, prime: 17)), {
                    $0.isNthPrimeRequestInFlight = false
                    $0.nthPrime = NthPrime(n: 4, prime: 17)
                }),
                Step(.send, .counter(.alertDismissButtonTapped), { $0.nthPrime = nil }),
            ]
        )
    }

    func testNthPrimeButtonUnhappyFlow() {
        assert(
            initialValue: CounterFeatureState(count: 4, nthPrime: nil, isNthPrimeRequestInFlight: false),
            reducer: counterViewReducer,
            environment: { _ in .sync { nil } },
            steps: [
                Step(.send, .counter(.requestNthPrime), { $0.isNthPrimeRequestInFlight = true }),
                Step(.receive, .counter(.nthPrimeResponse(n: 4, prime: nil)), {
                    $0.isNthPrimeRequestInFlight = false
                    $0.nthPrime = NthPrime(n: 4)
                }),
            ]
        )
    }

    func testDeleteFavoritePrime() {
        assert(
            initialValue: CounterFeatureState(
                count: 7,
                favoritePrimes: [3, 5]
            ),
            reducer: counterViewReducer,
            environment: { _ in .sync { nil } },
            steps: [
                Step(.send, .primeModal(.saveFavoritePrime), { $0.favoritePrimes = [3, 5, 7] }),
                Step(.send, .primeModal(.deleteFavoritePrime), { $0.favoritePrimes = [3, 5] }),
            ]
        )
    }
}

extension CounterFeatureState: Modifiable {}
