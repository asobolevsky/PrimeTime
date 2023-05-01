//
//  CounterTests.swift
//  CounterTests
//
//  Created by Aleksei Sobolevskii on 2023-04-20.
//

import XCTest
@testable import Counter

final class CounterTests: XCTestCase {
    func testCounterIncrement() {
        var state = CounterViewState(
            count: 2,
            favoritePrimes: [3, 5],
            nthPrime: nil,
            nthPrimeButtonDisabled: false
        )
        let expectedState = state.modified(what: \.count, value: 3)

        let effects = counterViewReducer(&state, .counter(.increment))

        XCTAssertEqual(state, expectedState)
        XCTAssertTrue(effects.isEmpty)
    }

    func testCounterDecrement() {
        var state = CounterViewState(
            count: 2,
            favoritePrimes: [3, 5],
            nthPrime: nil,
            nthPrimeButtonDisabled: false
        )
        let expectedState = state.modified(what: \.count, value: 1)

        let effects = counterViewReducer(&state, .counter(.decrement))

        XCTAssertEqual(state, expectedState)
        XCTAssertTrue(effects.isEmpty)
    }

    func testNthPrimeButtonHappyFlow() {
        var state = CounterViewState(
            count: 7,
            favoritePrimes: [3, 5],
            nthPrime: nil,
            nthPrimeButtonDisabled: false
        )
        var expectedState = state.modified(what: \.nthPrimeButtonDisabled, value: true)

        var effects = counterViewReducer(&state, .counter(.nthPrimeButtonTapped))

        XCTAssertEqual(state, expectedState)
        XCTAssertEqual(effects.count, 1)

        expectedState = state
            .modified(what: \.nthPrime, value: NthPrime(prime: 7))
            .modified(what: \.nthPrimeButtonDisabled, value: false)
        effects = counterViewReducer(&state, .counter(.nthPrimeResponse(NthPrime(prime: 7))))

        XCTAssertEqual(state, expectedState)
        XCTAssertEqual(effects.count, 0)

        expectedState = state.modified(what: \.nthPrime, value: nil)
        effects = counterViewReducer(&state, .counter(.alertDismissButtonTapped))

        XCTAssertEqual(state, expectedState)
        XCTAssertEqual(effects.count, 0)
    }

    func testNthPrimeButtonUnhappyFlow() {
        var state = CounterViewState(
            count: 7,
            favoritePrimes: [3, 5],
            nthPrime: nil,
            nthPrimeButtonDisabled: false
        )
        var expectedState = state.modified(what: \.nthPrimeButtonDisabled, value: true)

        var effects = counterViewReducer(&state, .counter(.nthPrimeButtonTapped))

        XCTAssertEqual(state, expectedState)
        XCTAssertEqual(effects.count, 1)

        expectedState = state
            .modified(what: \.nthPrimeButtonDisabled, value: false)
        effects = counterViewReducer(&state, .counter(.nthPrimeResponse(nil)))

        XCTAssertEqual(state, expectedState)
        XCTAssertEqual(effects.count, 0)
    }

    func testDeleteFavoritePrime() {
        var state = CounterViewState(
            count: 3,
            favoritePrimes: [3, 5],
            nthPrime: nil,
            nthPrimeButtonDisabled: false
        )
        let expectedState = state.modified(what: \.favoritePrimes, value: [5])

        let effects = counterViewReducer(&state, .primeModal(.deleteFavoritePrime))

        XCTAssertEqual(state, expectedState)
        XCTAssertEqual(effects.count, 0)
    }

    func testDeleteFavoritePrime_notFavoritePrime() {
        var state = CounterViewState(
            count: 7,
            favoritePrimes: [3, 5],
            nthPrime: nil,
            nthPrimeButtonDisabled: false
        )
        let expectedState = state

        let effects = counterViewReducer(&state, .primeModal(.deleteFavoritePrime))

        XCTAssertEqual(state, expectedState)
        XCTAssertEqual(effects.count, 0)
    }

    func testSaveFavoritePrime() {
        var state = CounterViewState(
            count: 7,
            favoritePrimes: [3, 5],
            nthPrime: nil,
            nthPrimeButtonDisabled: false
        )
        let expectedState = state.modified(what: \.favoritePrimes, value: [3, 5, 7])

        let effects = counterViewReducer(&state, .primeModal(.saveFavoritePrime))

        XCTAssertEqual(state, expectedState)
        XCTAssertEqual(effects.count, 0)
    }
}


extension CounterViewState: Modifiable {}
