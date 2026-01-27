import Foundation

public protocol LinkGatewayProtocol {
    func fetchInitialResource() async -> (url: URL?, pathid: String?)
    func fetchInitialResource(queryItems: [URLQueryItem]?) async -> (url: URL?, pathid: String?)
    func fetchResourceWithPathid(_ pathid: String) async -> URL?
    func fetchResourceWithPathid(_ pathid: String, filter: String?) async -> URL?
    func checkResourceValidity(for url: URL) async -> Bool
}

public final class LinkGateway: NSObject, LinkGatewayProtocol, URLSessionDataDelegate {
   
    private let startURL: URL = URL(string: "https://fiftytrinity.com/PgzV6G")!
    private let baseCampaignURL: URL = URL(string: "https://fiftytrinity.com/PgzV6G")!
    private var redirectChain: [URL] = []
    private let redirectChainLock = NSLock()

    public override init() {
        super.init()
    }

  
    public func fetchInitialResource() async -> (url: URL?, pathid: String?) {
        return await fetchInitialResource(queryItems: nil)
    }

   
    public func fetchInitialResource(queryItems: [URLQueryItem]?) async -> (url: URL?, pathid: String?) {
        redirectChainLock.lock()
        redirectChain.removeAll()
        redirectChainLock.unlock()
        
        
        let start: URL = {
            guard let items = queryItems, items.isEmpty == false else { return startURL }
            var components = URLComponents(url: baseCampaignURL, resolvingAgainstBaseURL: false) ?? URLComponents()
            components.queryItems = items
            return components.url ?? startURL
        }()
        
        var request = URLRequest(url: start, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 20)
        request.httpMethod = "GET"
        let session = URLSession(configuration: .ephemeral, delegate: self, delegateQueue: nil)
        
        do {
            print("[GW] fetchInitialResource startURL=\(start.absoluteString)")
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse else { return (nil, nil) }
            print("[GW] initial response status=\(http.statusCode) finalURL=\(http.url?.absoluteString ?? "nil")")
            
            
            guard let finalURL = http.url else { return (nil, nil) }
            
         
            var foundPathid: String?
            redirectChainLock.lock()
            let chain = redirectChain
            redirectChainLock.unlock()
            
           
            for redirectURL in chain {
                print("[GW] redirect: \(redirectURL.absoluteString)")
                if let components = URLComponents(url: redirectURL, resolvingAgainstBaseURL: false),
                   let queryItems = components.queryItems,
                   let pathidItem = queryItems.first(where: { $0.name == "pathid" }),
                   let value = pathidItem.value, !value.isEmpty {
                    foundPathid = value
                    break
                }
            }
            
         
            if foundPathid == nil {
                if let components = URLComponents(url: finalURL, resolvingAgainstBaseURL: false),
                   let queryItems = components.queryItems,
                   let pathidItem = queryItems.first(where: { $0.name == "pathid" }),
                   let value = pathidItem.value, !value.isEmpty {
                    foundPathid = value
                }
            }
            print("[GW] found pathid=\(foundPathid ?? "nil")")
            
         
            let startDomain = (startURL.host ?? "").lowercased()
            
            
            for redirectURL in chain {
                let redirectHost = (redirectURL.host ?? "").lowercased()
                if !redirectHost.isEmpty && redirectHost != startDomain {
             
                    print("[GW] choose redirect URL=\(redirectURL.absoluteString)")
                    return (redirectURL, foundPathid)
                }
            }
            
    
            let finalHost = (finalURL.host ?? "").lowercased()
            if !finalHost.isEmpty && finalHost != startDomain {
               
                print("[GW] choose finalURL=\(finalURL.absoluteString)")
                return (finalURL, foundPathid)
            }
      
            if let htmlString = String(data: data, encoding: .utf8) {
             
                if let metaURL = extractURLFromHTML(htmlString) {
                    print("[GW] HTML redirect found URL=\(metaURL.absoluteString)")
                    return (metaURL, foundPathid)
                }
            }
            
      
            if let pid = foundPathid {
                print("[GW] same-domain final, keeping only pathid=\(pid)")
                return (nil, pid)
            }
            
            return (nil, nil)
            
        } catch {
            print("[GW] fetchInitialResource error=\(error.localizedDescription)")
            return (nil, nil)
        }
    }

    // MARK: - Fetch resource with pathid
    public func fetchResourceWithPathid(_ pathid: String) async -> URL? {
        return await fetchResourceWithPathid(pathid, filter: nil)
    }

    // MARK: - Fetch resource with pathid and optional filter
    public func fetchResourceWithPathid(_ pathid: String, filter: String?) async -> URL? {
        redirectChainLock.lock()
        redirectChain.removeAll()
        redirectChainLock.unlock()
        

        var components = URLComponents(url: baseCampaignURL, resolvingAgainstBaseURL: false) ?? URLComponents()
        var queryItems = components.queryItems ?? []
        queryItems.append(URLQueryItem(name: "pathid", value: pathid))
        if let filter = filter, !filter.isEmpty {
            queryItems.append(URLQueryItem(name: "filter", value: filter))
        }
        components.queryItems = queryItems
        
        guard let urlWithPathid = components.url else { return nil }
        
        var request = URLRequest(url: urlWithPathid, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 20)
        request.httpMethod = "GET"
        let session = URLSession(configuration: .ephemeral, delegate: self, delegateQueue: nil)
        
        do {
            print("[GW] fetchResourceWithPathid pathid=\(pathid) filter=\(filter ?? "nil") url=\(urlWithPathid.absoluteString)")
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse else { return nil }
            print("[GW] pathid response status=\(http.statusCode) finalURL=\(http.url?.absoluteString ?? "nil")")
            
            // Check if final response is valid (200...403)
            guard (200...403).contains(http.statusCode) else { return nil }
            
            guard let finalURL = http.url else { return nil }
            
            // Return final URL (prefer redirect chain last URL if it's different from start domain)
            let startDomain = baseCampaignURL.host ?? ""
            redirectChainLock.lock()
            let lastRedirect = redirectChain.last
            redirectChainLock.unlock()
            
            if let lastRedirect = lastRedirect,
               let lastHost = lastRedirect.host,
               lastHost != startDomain && !lastHost.contains(startDomain) {
                print("[GW] choose pathid redirect URL=\(lastRedirect.absoluteString)")
                return lastRedirect
            }
            
            // If final URL is different from start domain, return it
            if let finalHost = finalURL.host, finalHost != startDomain && !finalHost.contains(startDomain) {
                print("[GW] choose pathid finalURL=\(finalURL.absoluteString)")
                return finalURL
            }
            
            // Try to parse HTML for meta/JS redirects on same-domain
            if let htmlString = String(data: data, encoding: .utf8), let htmlURL = extractURLFromHTML(htmlString) {
                print("[GW] pathid HTML redirect found URL=\(htmlURL.absoluteString)")
                return htmlURL
            }

            // If still same domain → treat as no external url resolved
            print("[GW] pathid same-domain final, return nil to avoid saving base domain")
            return nil
            
        } catch {
            print("[GW] fetchResourceWithPathid error=\(error.localizedDescription)")
            return nil
        }
    }

    // MARK: - Check resource validity
    public func checkResourceValidity(for url: URL) async -> Bool {
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 20)
        request.httpMethod = "GET"
        let session = URLSession(configuration: .ephemeral, delegate: nil, delegateQueue: nil)
        
        do {
            let (_, response) = try await session.data(for: request)
            if let http = response as? HTTPURLResponse {
                let ok = http.statusCode == 200
                print("[GW] checkResourceValidity url=\(url.absoluteString) status=\(http.statusCode) ok=\(ok)")
                return ok
            }
            return false
        } catch {
            print("[GW] checkResourceValidity error=\(error.localizedDescription) url=\(url.absoluteString)")
            return false
        }
    }

    // MARK: - URLSessionDataDelegate - follow redirects and track them
    public func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest) async -> URLRequest? {
        if let redirectURL = request.url {
            redirectChainLock.lock()
            redirectChain.append(redirectURL)
            redirectChainLock.unlock()
            print("[GW] redirect captured status=\(response.statusCode) → \(redirectURL.absoluteString)")
        }
        return request
    }
    
    // MARK: - Helper: Extract URL from HTML (meta refresh, JavaScript redirect)
    private func extractURLFromHTML(_ html: String) -> URL? {
        // Try meta refresh: <meta http-equiv="refresh" content="0;url=...">
        if let metaRange = html.range(of: #"<meta[^>]*http-equiv=["']refresh["'][^>]*>"#, options: [.regularExpression, .caseInsensitive]) {
            let metaTag = String(html[metaRange])
            // Try different patterns for URL in meta refresh
            let patterns = [
                #"url=([^"'\s&;]+)"#,
                #"URL=([^"'\s&;]+)"#,
                #"content=["'][^"']*url=([^"'\s&;]+)"#,
                #"content=["'][^"']*URL=([^"'\s&;]+)"#
            ]
            for pattern in patterns {
                if let urlRange = metaTag.range(of: pattern, options: .regularExpression) {
                    var urlString = String(metaTag[urlRange])
                    urlString = urlString.replacingOccurrences(of: "url=", with: "", options: .caseInsensitive)
                    urlString = urlString.replacingOccurrences(of: "URL=", with: "", options: .caseInsensitive)
                    urlString = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
                    if urlString.hasPrefix("http"), let url = URL(string: urlString) {
                        return url
                    }
                }
            }
        }
        
        // Try JavaScript window.location variations
        let jsPatterns = [
            #"window\.location\s*=\s*["']([^"']+)["']"#,
            #"location\.href\s*=\s*["']([^"']+)["']"#,
            #"location\.replace\(["']([^"']+)["']"#,
            #"window\.location\.href\s*=\s*["']([^"']+)["']"#
        ]
        
        for pattern in jsPatterns {
            if let locationRange = html.range(of: pattern, options: .regularExpression) {
                let match = String(html[locationRange])
                if let urlRange = match.range(of: #"["']([^"']+)["']"#, options: .regularExpression) {
                    var urlString = String(match[urlRange])
                    urlString = urlString.replacingOccurrences(of: "\"", with: "")
                    urlString = urlString.replacingOccurrences(of: "'", with: "")
                    urlString = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
                    if urlString.hasPrefix("http"), let url = URL(string: urlString) {
                        return url
                    }
                }
            }
        }
        
        return nil
    }
}




