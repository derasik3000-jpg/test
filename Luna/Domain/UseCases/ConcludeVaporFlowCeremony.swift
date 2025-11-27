import Foundation

class ConcludeVaporFlowCeremony {
    private let vaporArchive: VaporFlowArchiveProtocol
    
    init(vaporArchive: VaporFlowArchiveProtocol) {
        self.vaporArchive = vaporArchive
    }
    
    func performCompletion(prism: VaporFlowPrism) {
        vaporArchive.appendQuantum(prism)
    }
}

