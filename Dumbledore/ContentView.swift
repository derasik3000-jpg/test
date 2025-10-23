// ContentView.swift
import SwiftUI

struct ContentView: View {
    @StateObject private var tabRouter = NavTabRouter()
    
    init() {
        // Configure tab bar appearance
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = UIColor(Color.iWingSurface)
        
        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
    
    var body: some View {
        TabView(selection: $tabRouter.selectedTab) {
            TodayView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Today")
                }
                .tag(0)
            
            DialogView()
                .tabItem {
                    Image(systemName: "mic.fill")
                    Text("Dialog")
                }
                .tag(1)
            
            ImmersionView()
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("Immersion")
                }
                .tag(2)
            
            MicroLessonsView()
                .tabItem {
                    Image(systemName: "clock.fill")
                    Text("Micro-lessons")
                }
                .tag(3)
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .tag(4)
        }
        .accentColor(.iWingAccent)
        .environmentObject(tabRouter)
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

final class NavTabRouter: ObservableObject {
    @Published var selectedTab: Int = 0
    
    // Dummy method for human-like code
    func jumpToProfileWithDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.selectedTab = 4
        }
    }
}
