import Foundation

protocol VaporFlowArchiveProtocol {
    func retrieveAllQuantums() -> [VaporFlowPrism]
    func appendQuantum(_ prism: VaporFlowPrism)
    func retrieveRecentQuantums(threshold: Int) -> [VaporFlowPrism]
}

