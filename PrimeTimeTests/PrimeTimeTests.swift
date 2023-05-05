//
//  PrimeTimeTests.swift
//  PrimeTimeTests
//
//  Created by Aleksei Sobolevskii on 2023-05-03.
//

@testable import Counter
@testable import FavoritePrimes
@testable import PrimeModal
@testable import PrimeTime

import CommonState
import ComposableArchitechture
import ComposableArchitechtureTestUtils
import SnapshotTesting
import SwiftUI
import XCTest

extension Snapshotting where Value: UIViewController, Format == UIImage {
  static var windowedImage: Snapshotting {
    return Snapshotting<UIImage, UIImage>.image.asyncPullback { vc in
      Async<UIImage> { callback in
        UIView.setAnimationsEnabled(false)
        let window = UIApplication.shared.windows.first!
        window.rootViewController = vc
        DispatchQueue.main.async {
          let image = UIGraphicsImageRenderer(bounds: window.bounds).image { ctx in
            window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
          }
          callback(image)
          UIView.setAnimationsEnabled(true)
        }
      }
    }
  }
}


final class PrimeTimeTests: XCTestCase {

    func testIntegration() {
        var fileClient = FileClient.mock
        fileClient.load = { _ in .sync { try? JSONEncoder().encode([2, 3, 5, 7]) } }

        assert(
            initialValue: AppState(count: 4),
            reducer: _appReducer,
            environment: .init(
                fileClient: fileClient,
                nthPrime: { _ in .sync { 17 } }
            ), steps: [
                Step(.send, .counterView(.counter(.nthPrimeButtonTapped))) { $0.nthPrimeButtonDisabled = true },
                Step(.receive, .counterView(.counter(.nthPrimeResponse(n: 4, prime: 17)))) {
                    $0.nthPrimeButtonDisabled = false
                    $0.nthPrime = NthPrime(n: 4, prime: 17)
                },
                Step(.send, .favoritePrimes(.loadFavoritePrimes)),
                Step(.receive, .favoritePrimes(.updateFavoritePrimes([2, 3, 5, 7]))) { $0.favoritePrimes = [2, 3, 5, 7] },
            ])
    }

    func testSnapshots() {
        let store = Store(initialValue: CounterViewState(), environment: { _ in .sync { nil } }, reducer: counterViewReducer)
        let view = CounterView(store: store)

        let vc = UIHostingController(rootView: view)
        vc.view.frame = UIScreen.main.bounds

        diffTool = "ksdiff"
        assertSnapshot(matching: vc, as: .windowedImage)

        store.send(.counter(.increment))
        assertSnapshot(matching: vc, as: .windowedImage)

        store.send(.counter(.increment))
        assertSnapshot(matching: vc, as: .windowedImage)

        store.send(.counter(.nthPrimeButtonTapped))
        assertSnapshot(matching: vc, as: .windowedImage)

        var expectation = self.expectation(description: "wait")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
          expectation.fulfill()
        }
        self.wait(for: [expectation], timeout: 0.5)
        assertSnapshot(matching: vc, as: .windowedImage)

        store.send(.counter(.alertDismissButtonTapped))
        expectation = self.expectation(description: "wait")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
          expectation.fulfill()
        }
        self.wait(for: [expectation], timeout: 0.5)
        assertSnapshot(matching: vc, as: .windowedImage)

        store.send(.counter(.nthPrimeButtonTapped))
        assertSnapshot(matching: vc, as: .windowedImage)

        store.send(.primeModal(.saveFavoritePrime))
        assertSnapshot(matching: vc, as: .windowedImage)

        store.send(.counter(.alertDismissButtonTapped))
        assertSnapshot(matching: vc, as: .windowedImage)
      }

}
