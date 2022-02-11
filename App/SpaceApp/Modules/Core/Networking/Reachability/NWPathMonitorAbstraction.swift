import Foundation
import Network

protocol NWPathMonitorProtocol {
    func start(queue: DispatchQueue)
    func setReachabilityObserver(handler: @escaping (_ isReachable: Bool) -> Void)
}

extension NWPathMonitor: NWPathMonitorProtocol {
    func setReachabilityObserver(handler: @escaping (_ isReachable: Bool) -> Void) {
        pathUpdateHandler = { nwPath in
            handler(nwPath.status == .satisfied)
        }
    }
}
