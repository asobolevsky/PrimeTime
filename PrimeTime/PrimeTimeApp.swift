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
    @StateObject private var store = Store(initialState: AppState(), reducer: appReducer)

    var body: some Scene {
        WindowGroup {
            ContentView(store: store)
        }
    }
}