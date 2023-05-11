//
//  PrimeTimeApp.swift
//  PrimeTime
//
//  Created by Aleksei Sobolevskii on 2023-04-20.
//

import ComposableArchitechture
import SwiftUI

@main
struct PrimeTimeApp: App {
    private let store = Store(initialValue: AppState(), reducer: appReducer, environment: AppEnvironment.live)

    var body: some Scene {
        WindowGroup {
            ContentView(store: store)
        }
    }
}
