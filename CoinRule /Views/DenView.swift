//
//  DenView.swift
//  Coin Rule
//
//  Wraps NestRootView and handles fallback on error (den = animal home).
//

import SwiftUI
import Combine

struct DenView: View {
    @StateObject private var model: DenViewModel

    init(initialURL: URL?) {
        _model = StateObject(wrappedValue: DenViewModel(initialURL: initialURL))
    }

    var body: some View {
        NestRootView(url: model.currentURL, onError: model.handleError)
    }
}

@MainActor
final class DenViewModel: ObservableObject {
    @Published var currentURL: URL?
    private let service = DenKeeperService.shared

    init(initialURL: URL?) {
        self.currentURL = initialURL
    }

    func handleError() {
        service.denKeeperTryFallbackURL { [weak self] success, url in
            Task { @MainActor in
                self?.currentURL = url
            }
        }
    }
}
