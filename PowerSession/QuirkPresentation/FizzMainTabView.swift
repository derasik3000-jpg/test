import SwiftUI

public struct FizzMainTabView: View {
    @State private var plinthSelectedTab = 0
    
    public init() {}
    
    public var body: some View {
        TabView(selection: $plinthSelectedTab) {
            VexReplacementsScreen(plinthVM: murkyBuildCatalogVM())
                .tabItem {
                    Label("Replacements", systemImage: "arrow.triangle.2.circlepath")
                }
                .tag(0)
            
            BrindleFiltersScreen(plinthVM: quellBuildFiltersVM())
                .tabItem {
                    Label("Filters", systemImage: "slider.horizontal.3")
                }
                .tag(1)
            
            SprocketJournalScreen(quirkVM: sternBuildJournalVM())
                .tabItem {
                    Label("Journal", systemImage: "book.fill")
                }
                .tag(2)
        }
    }
    
    private func murkyBuildCatalogVM() -> MurkyCatalogViewModel {
        let context = QuirkCoreDataStack.shared.fizzContext
        let repo = TarnReplacementRepositoryImpl(vexContext: context)
        let haptics = PlinthDefaultHaptics()
        let findUC = SternDefaultFindReplacements(plinthRepo: repo)
        let toggleFavUC = SternDefaultToggleFavorite(quirkRepo: repo, tarnHaptics: haptics)
        let settingsRepo = SternSettingsRepositoryImpl(brindleContext: context)
        
        return MurkyCatalogViewModel(
            sternFindUC: findUC,
            plinthToggleFavUC: toggleFavUC,
            murkySettings: settingsRepo
        )
    }
    
    private func quellBuildFiltersVM() -> QuellFiltersViewModel {
        let context = QuirkCoreDataStack.shared.fizzContext
        let settingsRepo = SternSettingsRepositoryImpl(brindleContext: context)
        return QuellFiltersViewModel(vexSettings: settingsRepo)
    }
    
    private func sternBuildJournalVM() -> TarnJournalViewModel {
        let context = QuirkCoreDataStack.shared.fizzContext
        let dateProvider = SternDefaultDateProvider()
        let logsRepo = QuellAppliedLogRepositoryImpl(fizzContext: context)
        let analyticsRepo = VexAnalyticsRepositoryImpl(murkyContext: context)
        
        return TarnJournalViewModel(
            quellDateProvider: dateProvider,
            tarnLogsRepo: logsRepo,
            plinthAnalytics: analyticsRepo
        )
    }
}

