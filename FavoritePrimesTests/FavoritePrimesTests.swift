//
//  FavoritePrimesTests.swift
//  FavoritePrimesTests
//
//  Created by Aleksei Sobolevskii on 2023-04-20.
//

@testable import FavoritePrimes
import ComposableArchitechture
import XCTest

final class FavoritePrimesTests: XCTestCase {
    func testDeleteFavoritePrimes() {
        var state = [2, 3, 5, 7]
        let effects = favoritePrimesReducer(state: &state, action: .deleteFavoritePrimes([2]))

        XCTAssertEqual(state, [2, 3, 7])
        XCTAssertTrue(effects.isEmpty)
    }

    func testSaveFavoritePrimes() {
        var state = [2, 3, 7]
        let effects = favoritePrimesReducer(state: &state, action: .saveFavoritePrimes)

        XCTAssertEqual(state, [2, 3, 7])
        XCTAssertEqual(effects.count, 1)
    }

    func testLoadFavoritePrimes() {
        var state = [2, 3, 7]
        let effects = favoritePrimesReducer(state: &state, action: .loadFavoritePrimes)

        XCTAssertEqual(state, [2, 3, 7])
        XCTAssertEqual(effects.count, 1)
    }

    func testUpdateFavoritePrimes() {
        var state: [Int] = []
        let effects = favoritePrimesReducer(state: &state, action: .updateFavoritePrimes([2, 3, 7]))

        XCTAssertEqual(state, [2, 3, 7])
        XCTAssertTrue(effects.isEmpty)
    }
}
