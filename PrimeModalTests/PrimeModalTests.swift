//
//  PrimeModalTests.swift
//  PrimeModalTests
//
//  Created by Aleksei Sobolevskii on 2023-04-20.
//

@testable import PrimeModal
import ComposableArchitechture
import XCTest

final class PrimeModalTests: XCTestCase {
    func testSaveFavoritePrime() {
        var state = (count: 7, favoritePrimes: [3, 5])
        let effects = primeModalReducer(state: &state, action: .saveFavoritePrime, environment: ())

        let (count, favoritePrimes) = state
        XCTAssertEqual(count, 7)
        XCTAssertEqual(favoritePrimes, [3, 5, 7])
        XCTAssert(effects.isEmpty)
    }

    func testDeleteFavoritePrime() {
        var state = (count: 7, favoritePrimes: [3, 5, 7])
        let effects = primeModalReducer(state: &state, action: .deleteFavoritePrime, environment: ())

        let (count, favoritePrimes) = state
        XCTAssertEqual(count, 7)
        XCTAssertEqual(favoritePrimes, [3, 5])
        XCTAssert(effects.isEmpty)
    }
}
