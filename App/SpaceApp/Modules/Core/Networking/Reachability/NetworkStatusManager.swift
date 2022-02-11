import Foundation
import Network

protocol NetworkStatusManaging {
    func isNetworkReachable() -> Bool
}

final class NetworkStatusManager: NetworkStatusManaging {
    // MARK: - Dependencies

    private let nwPathMonitor: NWPathMonitorProtocol
    private let monitorQueue: DispatchQueue

    // MARK: - Properties

    private var isConnectionActive: Bool = false

    // MARK: - Singleton

    static let shared = NetworkStatusManager()

    // MARK: - Initialization

    init(
        nwPathMonitor: NWPathMonitorProtocol = NWPathMonitor(),
        monitorQueue: DispatchQueue = .global()
    ) {
        self.nwPathMonitor = nwPathMonitor
        self.monitorQueue = monitorQueue
        setup()
    }

    // MARK: - Private API

    private func setup() {
        nwPathMonitor.start(queue: monitorQueue)
        nwPathMonitor.setReachabilityObserver { [weak self] isReachable in
            self?.isConnectionActive = isReachable
        }
    }

    // MARK: - Public API

    func isNetworkReachable() -> Bool {
        isConnectionActive
    }
}
