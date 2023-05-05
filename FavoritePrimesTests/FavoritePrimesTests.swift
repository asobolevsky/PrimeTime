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
        var state = FavoritePrimesState(primes: [2, 3, 5, 7])
        let environment: (FileClient, (Int) -> Effect<Int?>) = (
            FileClient.mock,
            { _ in .sync { nil } }
        )
        let effects = favoritePrimesReducer(state: &state, action: .deleteFavoritePrimes([2]), environment: environment)

        XCTAssertEqual(state.primes, [2, 3, 7])
        XCTAssertTrue(effects.isEmpty)
    }

    func testSaveFavoritePrimes() {
        var encodedData: Data?
        var environment: (fileClient: FileClient, (Int) -> Effect<Int?>) = (
            FileClient.mock,
            { _ in .sync { nil } }
        )
        environment.fileClient.save = { _, data in
                .fireAndForget {
                    encodedData = data
                }
        }

        var state = FavoritePrimesState(primes: [2, 3, 7])
        let effects = favoritePrimesReducer(state: &state, action: .saveFavoritePrimes, environment: environment)

        XCTAssertEqual(state.primes, [2, 3, 7])
        XCTAssertEqual(effects.count, 1)

        _ = effects[0].sink { _ in XCTFail() }

        XCTAssertNotNil(encodedData)

        let encodedState = try! JSONDecoder().decode([Int].self, from: encodedData!)
        XCTAssertEqual(encodedState, [2, 3, 7])
    }

    func testLoadFavoritePrimes() {
        let expectedState = [2, 5, 7]
        var environment: (fileClient: FileClient, (Int) -> Effect<Int?>) = (
            FileClient.mock,
            { _ in .sync { nil } }
        )
        environment.fileClient.load = { _ in
                .sync {
                    try! JSONEncoder().encode(expectedState)
                }
        }

        var state = FavoritePrimesState(primes: [])
        var effects = favoritePrimesReducer(state: &state, action: .loadFavoritePrimes, environment: environment)

        var nextAction: FavoritePrimesAction!
        let receivedCompletion = expectation(description: "receivedCompletion")
        _ = effects[0].sink(
            receiveCompletion: { _ in
                receivedCompletion.fulfill()
            },
            receiveValue: { action in
                nextAction = action
                XCTAssertEqual(action, .updateFavoritePrimes(expectedState))
            }
        )
        wait(for: [receivedCompletion], timeout: 0)

        effects = favoritePrimesReducer(state: &state, action: nextAction, environment: environment)

        XCTAssertEqual(state.primes, expectedState)
        XCTAssertEqual(effects.count, 0)
    }

    func testUpdateFavoritePrimes() {
        var state = FavoritePrimesState(primes: [])
        let environment: (fileClient: FileClient, (Int) -> Effect<Int?>) = (
            FileClient.mock,
            { _ in .sync { nil } }
        )
        let effects = favoritePrimesReducer(state: &state, action: .updateFavoritePrimes([2, 3, 7]), environment: environment)

        XCTAssertEqual(state.primes, [2, 3, 7])
        XCTAssertTrue(effects.isEmpty)
    }
}
