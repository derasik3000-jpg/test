import Foundation

protocol RestCycleArchiveProtocol {
    func retrieveAllCycles() -> [RestCyclePrism]
    func appendCycle(_ prism: RestCyclePrism)
    func retrieveRecentCycles(threshold: Int) -> [RestCyclePrism]
}

