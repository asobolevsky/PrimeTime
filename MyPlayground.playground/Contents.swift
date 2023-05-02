//import ComposableArchitechture
//import Counter
//import FavoritePrimes
import PlaygroundSupport
import SwiftUI
import Combine
import SafariServices

// MARK: -

//let favoritePrimesState = FavoritePrimesState(primes: [1, 3, 5, 7])
//let favoritePrimesStore = Store(initialValue: favoritePrimesState, reducer: favoritePrimesReducer)
//let favoritePrimesView = NavigationView {
//    FavoritePrimesView(store: favoritePrimesStore)
//}


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

//PlaygroundPage.current.liveView = UIHostingController(
//    rootView: favoritePrimesView
//        .frame(width: 375, height: 830)
//)


// MARK: -

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


// MARK: -

struct Environment {
    var date: () -> Date = Date.init
    var gitHub: GitHubProtocol = GitHub()
}

var Current = Environment()

protocol GitHubProtocol {
    func fetchRepos(onComplete completionHandler: (@escaping (Result<[GitHub.Repo], Error>) -> Void))
}

struct GitHubMock: GitHubProtocol {
    var result: Result<[GitHub.Repo], Error>?

    func fetchRepos(onComplete completionHandler: @escaping ((Result<[GitHub.Repo], Error>) -> Void)) {
        let repos = [
            GitHub.Repo(
                archived: false,
                description: "Blob's blog",
                htmlUrl: URL(string: "https://pointfree.co")!,
                name: "Blobblog",
                pushedAt: Date(timeIntervalSinceReferenceDate: 547000000)
            )
        ]
        completionHandler(.success(repos))
    }
}

struct GitHub: GitHubProtocol {
    struct Repo: Decodable {
        var archived: Bool
        var description: String?
        var htmlUrl: URL
        var name: String
        var pushedAt: Date?
    }

    func fetchRepos(onComplete completionHandler: (@escaping (Result<[GitHub.Repo], Error>) -> Void)) {
        dataTask("orgs/pointfreeco/repos", completionHandler: completionHandler)
    }

    private func dataTask<T: Decodable>(_ path: String, completionHandler: (@escaping (Result<T, Error>) -> Void)) {
        let request = URLRequest(url: URL(string: "https://api.github.com/" + path)!)
        URLSession.shared.dataTask(with: request) { data, urlResponse, error in
            do {
                if let error = error {
                    throw error
                } else if let data = data {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
                    formatter.locale = Locale(identifier: "en_US_POSIX")
                    formatter.timeZone = TimeZone(secondsFromGMT: 0)

                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .formatted(formatter)
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    completionHandler(.success(try decoder.decode(T.self, from: data)))
                } else {
                    fatalError()
                }
            } catch let finalError {
                completionHandler(.failure(finalError))
            }
        }.resume()
    }
}

struct Analytics {
    struct Event {
        var name: String
        var properties: [String: String]

        static func tappedRepo(_ repo: GitHub.Repo) -> Event {
            return Event(
                name: "tapped_repo",
                properties: [
                    "repo_name": repo.name,
                    "build": Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Unknown",
                    "release": Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown",
                    "screen_height": String(describing: UIScreen.main.bounds.height),
                    "screen_width": String(describing: UIScreen.main.bounds.width),
                    "system_name": UIDevice.current.systemName,
                    "system_version": UIDevice.current.systemVersion,
                ]
            )
        }
    }

    func track(_ event: Analytics.Event) {
        print("Tracked", event)
    }
}

class ReposViewController: UITableViewController {
    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var repos: [GitHub.Repo] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Point-Free Repos"
        view.backgroundColor = .white

        Current.gitHub.fetchRepos { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case let .success(repos):
                    self?.repos = repos
                        .filter { !$0.archived }
                        .sorted(by: {
                            guard let lhs = $0.pushedAt, let rhs = $1.pushedAt else { return false }
                            return lhs > rhs
                        })
                case let .failure(error):
                    let alert = UIAlertController(
                        title: "Something went wrong",
                        message: error.localizedDescription,
                        preferredStyle: .alert
                    )
                    self?.present(alert, animated: true, completion: nil)
                }
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repos.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let repo = repos[indexPath.row]

        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = repo.name
        cell.detailTextLabel?.text = repo.description

        let dateComponentsFormatter = DateComponentsFormatter()
        dateComponentsFormatter.allowedUnits = [.day, .hour, .minute, .second]
        dateComponentsFormatter.maximumUnitCount = 1
        dateComponentsFormatter.unitsStyle = .abbreviated

        let label = UILabel()
        if let pushedAt = repo.pushedAt {
            label.text = dateComponentsFormatter.string(from: pushedAt, to: Current.date())
        }
        label.sizeToFit()

        cell.accessoryView = label

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let repo = repos[indexPath.row]
        Analytics().track(.tappedRepo(repo))
        let vc = SFSafariViewController(url: repo.htmlUrl)
        present(vc, animated: true, completion: nil)
    }
}

//PlaygroundPage.current.needsIndefiniteExecution = true

let controller = UINavigationController(
    rootViewController: ReposViewController()
)

PlaygroundPage.current.liveView = controller
