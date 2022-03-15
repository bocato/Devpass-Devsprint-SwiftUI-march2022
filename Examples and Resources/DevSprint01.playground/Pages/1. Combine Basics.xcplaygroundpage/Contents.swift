import UIKit
import Combine
import Foundation

// MARK: - 1. Publishers
print("*** 1.1. Publishers ***")
/// A ``Publisher`` is the basic building block of combine,
/// and is something that will emit a value and you can subscribe on it.
/// Basically a materizalization of the Observer Pattern.

/// Most of the basic types can be turned into a publisher.
let stringPublisher = "Hello Devpass!".publisher

/// To observe a value emmited from a publisher, we need to subscribe to it.
/// To do so, we use the method ``.sink(receiveValue:)``
print("*** stringPublisher ***")
var stringPublisherValues: [Any] = .init()
_ = stringPublisher.sink { value in // ((Value) -> Void)
    stringPublisherValues.append(value) // They can emit zero or more values, until the finish.
}
// prints: ["H", "e", "l", "l", "o", " ", "D", "e", "v", "p", "a", "s", "s", "!"]
print(stringPublisherValues)
print("")

/// As said before, the ``.sink`` function can do a little bit more than just receiving values
/// its extended method is ``.sink(receiveCompletion:, receiveValue:)``.
/// - ``receiveCompletion`` returns a `completion` of type ``Subscribers.Completion<FailureType>``,
/// where ``FailureType`` is something that conforms to ``Swift.Error``.
/// The completion is an enum that is similar to ``Result`` and can return:
///     - ``.finished``: marks that events stream ended and we won't receive anything else.
///     - ``.failure(FailureType)``: also marks the end of the stream, but brings an `Failure` with it.
/// - ``receiveValue`` will return us the values of the stream like we saw on the exemple above
print("*** arrayPublisher ***")
let arrayPublisher = [0, 1, 2, 3, 4].publisher
var arrayPublisherEvents: [Any] = .init()
_ = arrayPublisher.sink(
    receiveCompletion: { completion in // ((Subscribers.Completion<Never>) -> Void)
        switch completion { // runs once
        case .finished:
            arrayPublisherEvents.append(Subscribers.Completion<Never>.finished)
        case let .failure(error):
            arrayPublisherEvents.append(error)
        }
    },
    receiveValue: { value in // runs every time there is change
        arrayPublisherEvents.append(value)
    }
)
// prints: [0, 1, 2, 3, 4, .finished]
print(arrayPublisherEvents)
print("")

// MARK: - 1.1. Publishers: Cancellable and AnyCancellable
print("*** 1.1. Publishers: Cancellable and AnyCancellable ***")
/// To be able to correctly manage the lifecycle of a subscription we need look into another important type which
/// is the ``Cancellable`` protocol, that normally appears in its type-erased version ``AnyCancellable``.
/// It lets us control how long a subscription will stay alive and active and as soon as it is dealocated or cancelled
/// and almost all combine API's return an `AnyCancellable` when called.
final class NumbersStreamController {
    /// Don't worry about ``numbersSender`` for now now, we will see how it works in detail later on.
    /// For now, you just need to know that this is something that can send events and you can observe
    /// its values and it won't die until one of this situations described below happen...
    let numbersSender: PassthroughSubject<Int, Never> = .init()
    private(set) var numbersSenderEvents: [Any] = .init()
    var numbersSenderCancellable: AnyCancellable?
    var onDeinitCalled: (() -> Void)?
    
    init() {
        subscribeToNumbersSender()
    }
    
    deinit { onDeinitCalled?() }
    
    private func subscribeToNumbersSender() {
        numbersSenderCancellable = numbersSender.sink(
            receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    self?.numbersSenderEvents.append(Subscribers.Completion<Never>.finished)
                case let .failure(error):
                    self?.numbersSenderEvents.append(error)
                }
            },
            receiveValue: { [weak self] value in
                self?.numbersSenderEvents.append(value)
            }
        )
    }

    func feedValuesToNumbersSender() {
        numbersSender.send(0) /// will trigger `receiveValue` with `value = 0`
        numbersSender.send(1) /// will trigger `receiveValue` with `value = 1`
        numbersSender.send(2) /// will trigger `receiveValue` with `value = 2`
    }

    func sendFinishEvent() {
        numbersSender.send(completion: .finished)
    }
    
    func sendNewValue(_ value: Int) {
        numbersSender.send(value)
    }

    func isCancelableStillHoldingSomething() -> Bool {
        let mirror = Mirror(reflecting: numbersSenderCancellable as Any)
        let isHoldingSomething = mirror
            .children
            .first(where: { $0.value is AnyCancellable })?
            .value != nil
        return isHoldingSomething
    }
}

/// The subscription will wont receive any more events if one of the situations below happen...
/// 1) A `.finished` event was received.
print("*** numbersStreamController1 ***")
let numbersStreamController1 = NumbersStreamController()
numbersStreamController1.feedValuesToNumbersSender()
print(numbersStreamController1.numbersSenderEvents) // prints: [0, 1, 2]
numbersStreamController1.sendFinishEvent()
print(numbersStreamController1.numbersSenderEvents) // prints: [0, 1, 2, .finished]
print(numbersStreamController1.isCancelableStillHoldingSomething()) // prints: true, because the subscription is still alive, but the stream is not.
numbersStreamController1.sendNewValue(99)
print(numbersStreamController1.numbersSenderEvents) // prints: [0, 1, 2, .finished], this means it didn't receive `99` because the steam had already `.finished`.
print("")

/// 2) The subscription (the `AnyCancellable` we are holding on to) was `manualy` cancelled.
print("*** numbersStreamController2 ***")
let numbersStreamController2 = NumbersStreamController()
numbersStreamController2.feedValuesToNumbersSender()
print(numbersStreamController2.numbersSenderEvents) // prints: [0, 1, 2]
numbersStreamController2.numbersSenderCancellable?.cancel() // cancels the subscription
print(numbersStreamController2.isCancelableStillHoldingSomething()) // prints: true, because the subscription is still alive, but the stream is not.
numbersStreamController2.sendNewValue(195)
print(numbersStreamController2.numbersSenderEvents) // prints: [0, 1, 2], this means it didn't receive `195` because the steam was cancelled.
print("")

/// 3) The subscription (the `AnyCancellable` we are holding on to) was set to `nil`.
print("*** numbersStreamController3 ***")
let numbersStreamController3 = NumbersStreamController()
numbersStreamController3.feedValuesToNumbersSender()
print(numbersStreamController3.numbersSenderEvents) // prints: [0, 1, 2]
numbersStreamController3.numbersSenderCancellable = nil // cancels the subscription
print(numbersStreamController3.isCancelableStillHoldingSomething()) // prints: false, because the subscription is now dead, so the stream is also dead.
numbersStreamController3.sendNewValue(42)
print(numbersStreamController3.numbersSenderEvents) // prints: [0, 1, 2], this means it didn't receive `42` because the steam is dead.
print("")

/// 4) The parent object dies (is dealocated), then the subscription dies with it.
print("*** numbersStreamController4 ***")
var numbersStreamController4: NumbersStreamController? = .init()
var wasDeInitCalled: Bool = false
numbersStreamController4?.onDeinitCalled = { wasDeInitCalled = true }
numbersStreamController4?.feedValuesToNumbersSender()
print(numbersStreamController4?.numbersSenderEvents ?? "") // prints: [0, 1, 2]
numbersStreamController4 = nil // this would be the same as the object receives a call to deinit (the system dealocated it)
print(wasDeInitCalled == true) // prints: true, since the object was set to nil and is now dead... If the object is dead, everything inside it is also dead, so our subscription is gone.
print("")

// MARK: - 1.2. Publishers: AnyPublisher
print("*** 1.2. Publishers: AnyPublisher ***")
/// What is ``AnyPublisher``?
/// From Apple documentation:
/// - A publisher that performs type erasure by wrapping another publisher.
/// - ``AnyPublisher`` is a concrete implementation of ``Publisher`` that has no significant properties of its own, and passes through elements and completion values from its upstream publisher.
/// - Use ``AnyPublisher`` to wrap a publisher whose type has details you don’t want to expose across API boundaries, such as different modules. Wrapping a ``Subject`` with ``AnyPublisher`` also prevents callers from accessing its ``Subject/send(_:)`` method. When you use type erasure this way, you can change the underlying publisher implementation over time without affecting existing clients.
/// - You can use Combine’s ``Publisher/eraseToAnyPublisher()`` operator to wrap a publisher with ``AnyPublisher``.
print("*** AnyPublisher - MessagesManager ***")
final class MessagesManager {
    private let subject = PassthroughSubject<String, Never>()
    var publisher: AnyPublisher<String, Never> {
        subject.eraseToAnyPublisher()
    }
    
    func sendMessage(_ message: String) {
        subject.send(message)
    }
}

let messagesManager: MessagesManager = .init()
messagesManager.publisher.sink { messsage in
    print(messsage)
}
messagesManager.sendMessage("Hello!") // prints: "Hello"
// messagesManager.publisher // if we access the `publisher` property, we will be able to only sink on it, encapsulating the `PassthroughSubject` logic inside `MessagesManager` and avoiding api consumers from doing something we don't want them to.
print("")

// MARK: - 1.3. Publishers: Convenience Publishers
print("*** 1.3. Publishers: Convenience Publishers ***")
/// ``Future``: A publisher that eventually produces a single value and then finishes or fails.
print("*** Future ***")
func getData(then completion: @escaping (Result<String, NSError>) -> Void) {
    completion(.success("It works!"))
}
var returnFromGetData: [Any] = .init()
getData { result in
    returnFromGetData.append(result)
}
print("returnFromGetData:", returnFromGetData) // prints: [.success("It works!")]

func getDataUsingCombine() -> AnyPublisher<String, NSError> {
    let myFuture = Future<String, NSError> { promise in
        getData { result in
            switch result {
            case let .success(string):
                promise(.success(string))
            case let .failure(error):
                promise(.failure(error))
            }
        }
    }
    return myFuture.eraseToAnyPublisher()
}

var returnFromGetDataUsingCombine: [Any] = .init()
_ = getDataUsingCombine()
    .sink(
        receiveCompletion: { completion in
            returnFromGetDataUsingCombine.append(completion)
        },
        receiveValue: { value in
            returnFromGetDataUsingCombine.append(value)
        }
    )
print("returnFromGetDataUsingCombine:", returnFromGetDataUsingCombine) // prints: ["It works!", .finished]
print("")

/// ``Just``: A publisher that emits an output to each subscriber just once, and then finishes.
print("*** Just ***")
let justExample = Just<String>("Just this, then finish!")
var returnFromJustExample: [Any] = .init()
_ = justExample.sink(
    receiveCompletion: { completion in
        returnFromJustExample.append(completion)
    },
    receiveValue: { value in
        returnFromJustExample.append(value)
    }
)
print("returnFromJustExample:", returnFromJustExample) // prints: ["Just this, then finish!", .finished]
print("")

/// ``Empty``: A publisher that never publishes any values, and optionally finishes immediately.
print("*** Empty ***")
let emptyExample: Empty<String, NSError> = .init()
var returnFromEmptyExample: [Any] = .init()
_ = emptyExample.sink(
    receiveCompletion: { completion in
        returnFromEmptyExample.append(completion)
    },
    receiveValue: { value in
        returnFromEmptyExample.append(value)
    }
)
print("returnFromEmptyExample:", returnFromEmptyExample) // prints: [.finished]
print("")

/// ``Fail``: A publisher that immediately terminates with the specified error.
print("*** Fail ***")
let error: NSError = .init(domain: "FailExample", code: -1, userInfo: nil)
let failExample = Fail<String, NSError>(error: error)
var returnFromFailExample: [Any] = .init()
_ = failExample.sink(
    receiveCompletion: { completion in
        returnFromFailExample.append(completion)
    },
    receiveValue: { value in
        returnFromFailExample.append(value)
    }
)
print("returnFromFailExample:", returnFromFailExample) // prints: [.failure(Error Domain=FailExample Code=-1 "(null)")]
print("")


/// Creating a simple network thing from what we saw, also using modifiers...
enum NetworkError: Error {
    case invalidURL
    case invalidData
    case invalidResponse
    case someOtherError(Error)
}

/// New Combine API's
func getDataFromGoogle(url urlString: String) -> AnyPublisher<String, NetworkError> {
    guard let googleURL = URL(string: "www.google.com") else {
        return Fail(error: NetworkError.invalidURL)
            .eraseToAnyPublisher()
    }
    
    return URLSession
        .shared
        .dataTaskPublisher(for: googleURL)
        .tryMap { data, response -> String in
            
            guard
                let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200
            else { throw NetworkError.invalidResponse }
            
            guard
                let string = String(data: data, encoding: .utf8)
            else { throw NetworkError.invalidData }
            
            return string
        }
        .mapError { rawError -> NetworkError in
            switch rawError {
            case let networkError as NetworkError:
                return networkError
            default:
                return .someOtherError(rawError)
            }
        }
        .eraseToAnyPublisher()
}

/// "Old" closure-based API's
func getDataFromGoogleOLD(url urlString: String, completion: @escaping (Result<String, NetworkError>) -> Void) {
    guard let googleURL = URL(string: "www.google.com") else {
        completion(.failure(NetworkError.invalidURL))
        return
    }
    
    let getDataFromGoogleOLDTask = URLSession.shared.dataTask(with: googleURL) { data, response, error in
        
        if let rawError = error {
            completion(.failure(.someOtherError(rawError)))
            return
        }
        
        guard
            let httpResponse = response as? HTTPURLResponse,
            httpResponse.statusCode == 200
        else {
            completion(.failure(NetworkError.invalidResponse))
            return
        }
        
        guard
            let data = data,
            let string = String(data: data, encoding: .utf8)
        else {
            completion(.failure(NetworkError.invalidData))
            return
        }
        
        completion(.success(string))
    }
    getDataFromGoogleOLDTask.resume()
}

// MARK: - 1.4. Publishers: Operators
print("*** 1.4. Publishers: Operators ***")
/// They are methods that operate on a Publisher, perform some computation, and produce another Publisher in return.

/// The `.map` operator transforms an value into another.
print("*** map ***")
var transformedValues: [String] = .init()
["a", "b", "c"]
    .publisher
    .map { value in
        return value.uppercased()
    }.sink { transformedValue in
        transformedValues.append(transformedValue)
    }
print(transformedValues) // prints: ["A", "B", "C"]
print("")

/// `.map` can also pluck out a value in a more complicated publisher via `KeyPaths`
struct Pet {
    enum Kind {
        case cat
        case dog
    }
    let name: String
    let kind: Kind
}
var petNames: [String] = .init()
[Pet(name: "Torresmo", kind: .dog), Pet(name: "Boo", kind: .cat)]
    .publisher
    .map(\.name)
    .sink { name in
        petNames.append(name)
    }
print(petNames) // prints: ["Torresmo", "Boo"]
print("")

/// The `.tryMap` operator

// MARK: - 2. Subjects
print("*** 2. Subjects ***")
/// A ``Subject`` is a special form of ``Publisher`` that you can subscribe and also send events through it.
/// In `Combine` we have two kinds of `Subjects`: ``PassthroughSubject`` and ``CurrentValueSubject``.

/// - ``PassthroughSubject``:  returns values received after the subscription.
print("*** passthroughSubjectExample ***")
let passthroughSubjectExample: PassthroughSubject<Int, Never> = .init()
var passthroughSubjectExampleEvents: [Any] = .init()
passthroughSubjectExample.send(0) // sends a value down the stream, but it won't be printed because we did not subscribe yet
_ = passthroughSubjectExample.sink { value in
    passthroughSubjectExampleEvents.append(value)
    print(value)
}
passthroughSubjectExample.send(1) // sends a value down the stream and prints `1`, since we have sent it after subscribing
print("")

/// - ``CurrentValueSubject``: returns values the current value right after we subscribe, and all the subsequent values after that.
print("*** currentValueSubjectExample ***")
let currentValueSubjectExample: CurrentValueSubject<String, Never>
currentValueSubjectExample = .init("InitialValue") // sets the first value of the stream, that will be received as soon as we  subscribe to the subject
_ = currentValueSubjectExample.sink { value in
    print(value)
}
currentValueSubjectExample.send("Second") // sends a new value down the stream and it will be received right away, since we already have a subscription
print("")

/// On both objects, the most important methods besides ``sink`` are:
/// - ``send``: which will send a value to the stream like `mySubject.send(1)`
/// - ``send(completion:)``: which sends a completion to the stream, being that either a `.failure` or `.finished`.
///     - Use `mySubject.send(completion: .failure(someError))` to finish the stream with a falure.
///     - Use `mySubject.send(completion: .finished)` to simply mark the stream as `.finished` and stop receiving events.

// MARK: - 3. Schedulers
print("*** 3. Schedulers ***")
