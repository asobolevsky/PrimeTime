import ComposableArchitechture
import Counter
import FavoritePrimes
import PlaygroundSupport
import SwiftUI
import Combine

let favoritePrimesState = FavoritePrimesState(primes: [1, 3, 5, 7])
let favoritePrimesStore = Store(initialValue: favoritePrimesState, reducer: favoritePrimesReducer)
let favoritePrimesView = NavigationView {
    FavoritePrimesView(store: favoritePrimesStore)
}


//let counterState = CounterViewState(
//    count: 0,
//    favoritePrimes: FavoritePrimesState(primes: []),
//    nthPrime: nil,
//    nthPrimeButtonDisabled: false
//)
//let counterStore = Store(initialValue: counterState, reducer: logging(counterViewReducer))
//let counterView = CounterView(store: counterStore)
//
//let rootView = counterView

PlaygroundPage.current.liveView = UIHostingController(
    rootView: favoritePrimesView
        .frame(width: 375, height: 830)
)


//
//struct Effect<A> {
//    let run: (@escaping (A) -> Void) -> Void
//
//    func map<B>(_ f: @escaping (A) -> B) -> Effect<B> {
//        Effect<B> { callback in run { a in callback(f(a)) } }
//    }
//}
//
////let anIntInTwoSeconds = Effect<Int> { callback in
////    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
////        callback(42)
////    }
////}
////anIntInTwoSeconds.run { print($0) }
//
////var count = 0
////let iterator = AnyIterator.init {
////    count += 1
////    return count
////}
////
////print(Array(iterator.prefix(10)))
//
//var cancellables: Set<AnyCancellable> = []
//// Future init block is executed instantly (eager publisher)
////let aFutureInt = Future<Int, Never>.init { promise in
////    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
////        print("Hello from the future")
////        promise(.success(42))
////    }
////}
//let aFutureInt = Deferred {
//    Future<Int, Never>.init { promise in
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//            print("Hello from the future")
//            promise(.success(42))
//            promise(.success(1729))
//        }
//    }
//}
//
////let subscriber = AnySubscriber<Int, Never>.init(
////    receiveSubscription: { subscription in
////        subscription.request(.unlimited)
////        print("Subscribed")
////    },
////    receiveValue: { value in
////        print("value: \(value)")
////        return .unlimited
////    },
////    receiveCompletion: { completion in
////        print("Completed: \(completion)")
////    }
////)
////aFutureInt.subscribe(subscriber)
//
//let cancellable = aFutureInt
//    .sink { int in
//        print(int)
//    }
////cancellable.cancel()
//
//let passthrough = PassthroughSubject<Int, Never>()
//let currentValue = CurrentValueSubject<Int, Never>(2)
//
//let c1 = passthrough.sink { x in
//    print("passthrough: \(x)")
//}
//let c2 = currentValue.sink { x in
//    print("currentValue: \(x)")
//}

//PlaygroundPage.current.needsIndefiniteExecution = true
