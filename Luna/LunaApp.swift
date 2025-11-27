import SwiftUI

@main
struct LunaApp: App {
    @AppStorage("nightModeActivated") private var nightModeActivated = false
    
    var body: some Scene {
        WindowGroup {
            CelestialRootView()
                .preferredColorScheme(nightModeActivated ? .dark : .light)
        }
    }
}
