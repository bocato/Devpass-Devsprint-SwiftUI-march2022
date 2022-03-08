import UIKit
import Combine

// MARK: - 1. Publishers
/// A ``Publisher`` is the basic building block of combine,
/// and is something that will emit a value and you can subscribe on it.
/// Basically a materizalization of the Observer Pattern.

/// Most of the basic types can be turned into a publisher.
let stringPublisher = "Hello Devpass!".publisher

/// To observe a value emmited from a publisher, we need to subscribe to it.
/// To do so, we use the method ``.sink(receiveValue:)``
var stringPublisherValues: [Any] = .init()
_ = stringPublisher.sink { value in // ((Value) -> Void)
    stringPublisherValues.append(value) // They can emit zero or more values, until the finish.
}
// prints: ["H", "e", "l", "l", "o", " ", "D", "e", "v", "p", "a", "s", "s", "!"]
print(stringPublisherValues)

/// As said before, the ``.sink`` function can do a little bit more than just receiving values
/// its extended method is ``.sink(receiveCompletion:, receiveValue:)``.
/// - ``receiveCompletion`` returns a `completion` of type ``Subscribers.Completion<FailureType>``,
/// where ``FailureType`` is something that conforms to ``Swift.Error``.
/// The completion is an enum that is similar to ``Result`` and can return:
///     - ``.finished``: marks that events stream ended and we won't receive anything else.
///     - ``.failure(FailureType)``: also marks the end of the stream, but brings an `Failure` with it.
/// - ``receiveValue`` will return us the values of the stream like we saw on the exemple above
let arrayPublisher = [0, 1, 2, 3, 4].publisher
var arrayPublisherEvents: [Any] = .init()
_ = arrayPublisher.sink(
    receiveCompletion: { completion in // ((Subscribers.Completion<Never>) -> Void)
        switch completion {
        case .finished:
            arrayPublisherEvents.append(Subscribers.Completion<Never>.finished)
        case let .failure(error):
            arrayPublisherEvents.append(error)
        }
    },
    receiveValue: { value in
        arrayPublisherEvents.append(value)
    }
)
// prints: [0, 1, 2, 3, 4, .finished]
print(arrayPublisherEvents)

/// To be able to correctly manage the lifecycle of a subscription we need look into another important type which
/// is the ``Cancelable`` protocol, that normally appears in its type-erased version ``AnyCancellable``.
/// It lets us control how long a subscription will stay alive and active and as soon as it is dealocated or cancelled
/// its attached subscription will die (send the `.finished` event) and almost all combine API's return an
/// `AnyCancelable` when called.
final class NumbersStreamController {
    /// Don't worry about ``numbersSender`` for now now, we will see how it works in detail later on.
    /// For now, you just need to know that this is something that can send events and you can observe
    /// its values and it won't die until one of this situations described below happen...
    private let numbersSender: PassthroughSubject<Int, Never> = .init()
    private(set) var numbersSenderEvents: [Any] = .init()
    var numbersSenderCancellable: AnyCancellable?
    init() {
        numbersSenderCancellable = numbersSender.sink(
            receiveCompletion: { completion in
                switch completion {
                case .finished:
                    self.numbersSenderEvents.append(Subscribers.Completion<Never>.finished)
                case let .failure(error):
                    self.numbersSenderEvents.append(error)
                }
            },
            receiveValue: { value in
                self.numbersSenderEvents.append(value)
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

    func printNumbersSenderCancellableStatus() {
        let mirror = Mirror(reflecting: numbersSenderCancellable)
        print(mirror.children.first)
    }
}

/// 1) A `.finished` event was received.
let numbersStreamController1 = NumbersStreamController()
numbersStreamController1.feedValuesToNumbersSender()
print(numbersStreamController1.numbersSenderEvents) // prints: [0, 1, 2]
numbersStreamController1.sendFinishEvent()
print(numbersStreamController1.numbersSenderEvents) // prints: [0, 1, 2, .finished]

/// 2) The subscription was `manualy` cancelled.


/// 3) The parent object dies (is dealocated), then the subscription dies with it.


