import SwiftUI
import CoreData
import Combine

public class LibraryVM: ObservableObject {
    @Published public var query: String = ""
    @Published public var articles: [ArticleDTO] = []
    @Published public var selectedCategory: ArticleCategory? = nil
    @Published public var bookmarkedSlugs: Set<String> = []
    @Published public var isSearching: Bool = false
    
    private let repo: ArticleRepository
    
    public init(repo: ArticleRepository) {
        self.repo = repo
        loadBookmarks()
        reload()
    }
    
    public func reload() {
        var results = query.isEmpty ? repo.all() : repo.search(query)
        
        if let category = selectedCategory {
            results = results.filter { $0.tags.contains(category.rawValue) }
        }
        
        articles = results
        
        print("📖 Reloaded articles: \(articles.count) total")
        print("🔖 Bookmarked slugs: \(bookmarkedSlugs)")
        let bookmarkedArticles = articles.filter { bookmarkedSlugs.contains($0.slug) }
        print("📚 Bookmarked articles found: \(bookmarkedArticles.count)")
        bookmarkedArticles.forEach { article in
            print("  - \(article.title) (slug: \(article.slug))")
        }
    }
    
    public func open(slug: String) -> ArticleDTO? {
        repo.bySlug(slug)
    }
    
    public func toggleBookmark(_ article: ArticleDTO) {
        if bookmarkedSlugs.contains(article.slug) {
            bookmarkedSlugs.remove(article.slug)
            print("🔖 Removed bookmark for: \(article.title) (slug: \(article.slug))")
        } else {
            bookmarkedSlugs.insert(article.slug)
            print("🔖 Added bookmark for: \(article.title) (slug: \(article.slug))")
        }
        saveBookmarks()
        
        // Force UI update
        objectWillChange.send()
    }
    
    public func isBookmarked(_ article: ArticleDTO) -> Bool {
        bookmarkedSlugs.contains(article.slug)
    }
    
    public var bookmarkedArticles: [ArticleDTO] {
        let allArticles = repo.all()
        let bookmarked = allArticles.filter { bookmarkedSlugs.contains($0.slug) }
        print("🔍 Getting bookmarked articles: \(bookmarked.count) out of \(allArticles.count) total")
        bookmarked.forEach { article in
            print("  - \(article.title) (slug: \(article.slug))")
        }
        return bookmarked
    }
    
    private func loadBookmarks() {
        // Try to load new slug-based bookmarks first
        if let data = UserDefaults.standard.data(forKey: "article_bookmarks_v2"),
           let slugs = try? JSONDecoder().decode(Set<String>.self, from: data) {
            bookmarkedSlugs = slugs
            print("📚 Loaded \(slugs.count) bookmarks (slugs)")
        } else {
            print("📚 No bookmarks found")
        }
    }
    
    private func saveBookmarks() {
        if let data = try? JSONEncoder().encode(bookmarkedSlugs) {
            UserDefaults.standard.set(data, forKey: "article_bookmarks_v2")
            UserDefaults.standard.synchronize()
            print("💾 Saved \(bookmarkedSlugs.count) bookmarks (slugs)")
        } else {
            print("❌ Failed to save bookmarks")
        }
    }
}

// MARK: - Article Category

public enum ArticleCategory: String, CaseIterable {
    case injury = "Injury"
    case recovery = "Recovery"
    case prevention = "Prevention"
    case exercise = "Exercise"
    case nutrition = "Nutrition"
    
    var icon: String {
        switch self {
        case .injury: return "bandage"
        case .recovery: return "heart.circle"
        case .prevention: return "shield.checkered"
        case .exercise: return "figure.run"
        case .nutrition: return "leaf"
        }
    }
    
    var color: Color {
        switch self {
        case .injury: return ThemeColorsConfig.accentWarm
        case .recovery: return ThemeColorsConfig.accentBright
        case .prevention: return Color(hex: "A78BFA")
        case .exercise: return Color(hex: "FFB84D")
        case .nutrition: return Color(hex: "34D399")
        }
    }
}

// MARK: - Main View

public struct LibraryTabView: View {
    @StateObject var viewModel: LibraryVM
    @State private var appeared = false
    @State private var searchFocused = false
    @State private var selectedArticle: ArticleDTO?
    @FocusState private var isSearchFieldFocused: Bool
    
    public init(viewModel: LibraryVM) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        NavigationView {
            ZStack {
                ThemeColorsConfig.backgroundDeep
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Search Bar
                        SearchBarView(
                            query: $viewModel.query,
                            isSearching: $viewModel.isSearching,
                            onQueryChange: { viewModel.reload() }
                        )
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        
                        // Categories
                        CategoryScrollView(
                            selectedCategory: $viewModel.selectedCategory,
                            onSelect: { viewModel.reload() }
                        )
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 10)
                        
                        // Bookmarked Section
                        if !viewModel.bookmarkedSlugs.isEmpty && viewModel.query.isEmpty && viewModel.selectedCategory == nil {
                            BookmarkedSection(
                                articles: viewModel.bookmarkedArticles,
                                viewModel: viewModel,
                                appeared: appeared,
                                onArticleTap: { article in
                                    selectedArticle = article
                                }
                            )
                        }
                        
                        // Articles List
                        ArticlesListSection(
                            articles: viewModel.articles,
                            viewModel: viewModel,
                            appeared: appeared,
                            onArticleTap: { article in
                                selectedArticle = article
                            }
                        )
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 120)
                }
                
                NavigationLink(
                    destination: selectedArticle.map { ArticleDetailView(article: $0, viewModel: viewModel) },
                    isActive: Binding(
                        get: { selectedArticle != nil },
                        set: { if !$0 { selectedArticle = nil } }
                    )
                ) {
                    EmptyView()
                }
                .hidden()
            }
            .navigationTitle("Knowledge Base")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                    appeared = true
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}

// MARK: - Search Bar

struct SearchBarView: View {
    @Binding var query: String
    @Binding var isSearching: Bool
    let onQueryChange: () -> Void
    
    @State private var isFocused = false
    
    var body: some View {
        HStack(spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isFocused ? ThemeColorsConfig.accentBright : ThemeColorsConfig.neutralAxis)
                
                TextField("Search articles...", text: $query, onEditingChanged: { editing in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isFocused = editing
                        isSearching = editing
                    }
                })
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(ThemeColorsConfig.primaryLight)
                .accentColor(ThemeColorsConfig.accentBright)
                .onChange(of: query) { _ in
                    onQueryChange()
                }
                
                if !query.isEmpty {
                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            query = ""
                        }
                        onQueryChange()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(ThemeColorsConfig.neutralAxis)
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(ThemeColorsConfig.backgroundCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(
                                isFocused ? ThemeColorsConfig.accentBright.opacity(0.5) : ThemeColorsConfig.neutralMuted.opacity(0.3),
                                lineWidth: 1
                            )
                    )
            )
            
            if isSearching {
                Button("Cancel") {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        query = ""
                        isSearching = false
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                    onQueryChange()
                }
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(ThemeColorsConfig.accentBright)
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isSearching)
    }
}

// MARK: - Category Scroll

struct CategoryScrollView: View {
    @Binding var selectedCategory: ArticleCategory?
    let onSelect: () -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                // All button
                CategoryChip(
                    title: "All",
                    icon: "square.grid.2x2",
                    color: ThemeColorsConfig.accentBright,
                    isSelected: selectedCategory == nil
                ) {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        selectedCategory = nil
                    }
                    onSelect()
                }
                
                ForEach(ArticleCategory.allCases, id: \.self) { category in
                    CategoryChip(
                        title: category.rawValue,
                        icon: category.icon,
                        color: category.color,
                        isSelected: selectedCategory == category
                    ) {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                            selectedCategory = category
                        }
                        onSelect()
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

struct CategoryChip: View {
    let title: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            action()
        }) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
            }
            .foregroundColor(isSelected ? ThemeColorsConfig.backgroundDeep : color)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(isSelected ? color : color.opacity(0.15))
            )
            .overlay(
                Capsule()
                    .stroke(color.opacity(isSelected ? 0 : 0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Bookmarked Section

struct BookmarkedSection: View {
    let articles: [ArticleDTO]
    @ObservedObject var viewModel: LibraryVM
    let appeared: Bool
    let onArticleTap: (ArticleDTO) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "bookmark.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(ThemeColorsConfig.accentWarm)
                
                Text("Saved Articles")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(ThemeColorsConfig.primaryLight)
                
                Spacer()
                
                Text("\(articles.count)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(ThemeColorsConfig.neutralAxis)
            }
            .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(articles) { article in
                        Button {
                            onArticleTap(article)
                        } label: {
                            BookmarkedArticleCard(article: article)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 15)
    }
}

struct BookmarkedArticleCard: View {
    let article: ArticleDTO
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Icon
            ZStack {
                Circle()
                    .fill(ThemeColorsConfig.accentBright.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(ThemeColorsConfig.accentBright)
            }
            
            Text(article.title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(ThemeColorsConfig.primaryLight)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            let readTime = estimateReadTime(article.body)
            HStack(spacing: 4) {
                Image(systemName: "clock")
                    .font(.system(size: 10, weight: .medium))
                Text("\(readTime) min")
                    .font(.system(size: 11, weight: .medium))
            }
            .foregroundColor(ThemeColorsConfig.neutralAxis)
        }
        .frame(width: 140, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(ThemeColorsConfig.backgroundCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(ThemeColorsConfig.accentWarm.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private func estimateReadTime(_ text: String) -> Int {
        let wordCount = text.split(separator: " ").count
        return max(1, wordCount / 200)
    }
}

// MARK: - Articles List Section

struct ArticlesListSection: View {
    let articles: [ArticleDTO]
    @ObservedObject var viewModel: LibraryVM
    let appeared: Bool
    let onArticleTap: (ArticleDTO) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("All Articles")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(ThemeColorsConfig.primaryLight)
                
                Spacer()
                
                Text("\(articles.count) articles")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(ThemeColorsConfig.neutralAxis)
            }
            
            if articles.isEmpty {
                EmptyArticlesView()
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(Array(articles.enumerated()), id: \.element.id) { index, article in
                        Button {
                            onArticleTap(article)
                        } label: {
                            ArticleRowView(
                                article: article,
                                isBookmarked: viewModel.isBookmarked(article),
                                onBookmark: { viewModel.toggleBookmark(article) }
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 20)
                        .animation(
                            .spring(response: 0.5, dampingFraction: 0.7)
                            .delay(Double(index) * 0.05),
                            value: appeared
                        )
                    }
                }
            }
        }
    }
}

// MARK: - Empty State

struct EmptyArticlesView: View {
    @State private var floating = false
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(ThemeColorsConfig.accentBright.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "doc.text.magnifyingglass")
                    .font(.system(size: 36, weight: .light))
                    .foregroundColor(ThemeColorsConfig.accentBright.opacity(0.6))
                    .offset(y: floating ? -3 : 3)
            }
            
            VStack(spacing: 6) {
                Text("No Articles Found")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(ThemeColorsConfig.primaryLight)
                
                Text("Try adjusting your search or filters")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(ThemeColorsConfig.neutralAxis)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                floating = true
            }
        }
    }
}

// MARK: - Article Row

struct ArticleRowView: View {
    let article: ArticleDTO
    let isBookmarked: Bool
    let onBookmark: () -> Void
    
    private var primaryTag: ArticleCategory? {
        article.tags.compactMap { ArticleCategory(rawValue: $0) }.first
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            // Category icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill((primaryTag?.color ?? ThemeColorsConfig.accentBright).opacity(0.15))
                    .frame(width: 48, height: 48)
                
                Image(systemName: primaryTag?.icon ?? "doc.text")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(primaryTag?.color ?? ThemeColorsConfig.accentBright)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(article.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(ThemeColorsConfig.primaryLight)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Text(article.body.prefix(80) + "...")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(ThemeColorsConfig.neutralAxis)
                    .lineLimit(2)
                
                // Tags & Read time
                HStack(spacing: 8) {
                    let readTime = estimateReadTime(article.body)
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 10, weight: .medium))
                        Text("\(readTime) min read")
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundColor(ThemeColorsConfig.neutralAxis)
                    
                    if !article.tags.isEmpty {
                        Circle()
                            .fill(ThemeColorsConfig.neutralMuted)
                            .frame(width: 3, height: 3)
                        
                        Text(article.tags.prefix(2).joined(separator: ", "))
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(ThemeColorsConfig.accentBright)
                    }
                }
            }
            
            Spacer(minLength: 8)
            
            // Bookmark button
            Button {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                onBookmark()
            } label: {
                Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(isBookmarked ? ThemeColorsConfig.accentWarm : ThemeColorsConfig.neutralMuted)
                    .padding(8)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(ThemeColorsConfig.backgroundCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(ThemeColorsConfig.neutralMuted.opacity(0.25), lineWidth: 1)
                )
        )
        .contentShape(Rectangle())
    }
    
    private func estimateReadTime(_ text: String) -> Int {
        let wordCount = text.split(separator: " ").count
        return max(1, wordCount / 200)
    }
}

// MARK: - Article Detail View

struct ArticleDetailView: View {
    let article: ArticleDTO
    @ObservedObject var viewModel: LibraryVM
    
    @State private var appeared = false
    @State private var scrollOffset: CGFloat = 0
    
    private var isBookmarked: Bool {
        viewModel.isBookmarked(article)
    }
    
    var body: some View {
        ZStack {
            ThemeColorsConfig.backgroundDeep
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom navigation bar with back button
                HStack {
                    NavigationBackButton()
                    
                    Spacer()
                    
                    Text("Article")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(ThemeColorsConfig.primaryLight)
                    
                    Spacer()
                    
                    Button {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        viewModel.toggleBookmark(article)
                    } label: {
                        Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(isBookmarked ? ThemeColorsConfig.accentWarm : ThemeColorsConfig.primaryLight)
                    }
                    
                    Button {
                        let activityVC = UIActivityViewController(
                            activityItems: [article.title],
                            applicationActivities: nil
                        )
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let window = windowScene.windows.first,
                           let rootVC = window.rootViewController {
                            activityVC.popoverPresentationController?.sourceView = window
                            rootVC.present(activityVC, animated: true)
                        }
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(ThemeColorsConfig.primaryLight)
                    }
                    .padding(.leading, 16)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(ThemeColorsConfig.backgroundDeep)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Header
                        ArticleHeader(
                            article: article,
                            isBookmarked: isBookmarked,
                            onBookmark: { viewModel.toggleBookmark(article) },
                            appeared: appeared
                        )
                        
                        // Body
                        ArticleBodyView(bodyText: article.body, appeared: appeared)
                        
                        // External Link
                        if let externalURL = article.externalURL, let url = URL(string: externalURL) {
                            ExternalLinkCard(url: url, appeared: appeared)
                        }
                        
                        // Related tags
                        if !article.tags.isEmpty {
                            RelatedTagsView(tags: article.tags, appeared: appeared)
                        }
                    }
                    .padding(20)
                    .padding(.bottom, 20)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                appeared = true
            }
        }
    }
}

// MARK: - Article Header

struct ArticleHeader: View {
    let article: ArticleDTO
    let isBookmarked: Bool
    let onBookmark: () -> Void
    let appeared: Bool
    
    private var primaryTag: ArticleCategory? {
        article.tags.compactMap { ArticleCategory(rawValue: $0) }.first
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Category badge
            if let tag = primaryTag {
                HStack(spacing: 6) {
                    Image(systemName: tag.icon)
                        .font(.system(size: 12, weight: .semibold))
                    Text(tag.rawValue)
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundColor(tag.color)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(tag.color.opacity(0.15))
                )
            }
            
            // Title
            Text(article.title)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(ThemeColorsConfig.primaryLight)
                .lineSpacing(4)
            
            // Meta info
            HStack(spacing: 16) {
                let readTime = estimateReadTime(article.body)
                HStack(spacing: 6) {
                    Image(systemName: "clock")
                        .font(.system(size: 13, weight: .medium))
                    Text("\(readTime) min read")
                        .font(.system(size: 13, weight: .medium))
                }
                .foregroundColor(ThemeColorsConfig.neutralAxis)
                
                if article.externalURL != nil {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 13, weight: .medium))
                        Text("Verified")
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundColor(ThemeColorsConfig.accentBright)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
    }
    
    private func estimateReadTime(_ text: String) -> Int {
        let wordCount = text.split(separator: " ").count
        return max(1, wordCount / 200)
    }
}

// MARK: - Article Body

struct ArticleBodyView: View {
    let bodyText: String
    let appeared: Bool
    
    var body: some View {
        Text(bodyText)
            .font(.system(size: 16, weight: .regular))
            .foregroundColor(ThemeColorsConfig.primaryLight.opacity(0.9))
            .lineSpacing(8)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 15)
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: appeared)
    }
}

// MARK: - External Link Card

struct ExternalLinkCard: View {
    let url: URL
    let appeared: Bool
    
    @State private var isPressed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "link.badge.plus")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(ThemeColorsConfig.accentBright)
                
                Text("Verified Medical Source")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(ThemeColorsConfig.primaryLight)
            }
            
            Text("This article references peer-reviewed medical literature")
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(ThemeColorsConfig.neutralAxis)
            
            Link(destination: url) {
                HStack {
                    Image(systemName: "safari.fill")
                        .font(.system(size: 18, weight: .medium))
                    
                    Text("Read Original Source")
                        .font(.system(size: 15, weight: .semibold))
                    
                    Spacer()
                    
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundColor(ThemeColorsConfig.backgroundDeep)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(ThemeColorsConfig.accentBright)
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(ThemeColorsConfig.backgroundCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(ThemeColorsConfig.accentBright.opacity(0.3), lineWidth: 1)
                )
        )
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 15)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: appeared)
    }
}

// MARK: - Related Tags

struct RelatedTagsView: View {
    let tags: [String]
    let appeared: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Topics")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(ThemeColorsConfig.neutralAxis)
            
            WrappingHStack(spacing: 8) {
                ForEach(tags, id: \.self) { tag in
                    let category = ArticleCategory(rawValue: tag)
                    
                    HStack(spacing: 6) {
                        if let cat = category {
                            Image(systemName: cat.icon)
                                .font(.system(size: 11, weight: .semibold))
                        }
                        Text(tag)
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundColor(category?.color ?? ThemeColorsConfig.accentBright)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill((category?.color ?? ThemeColorsConfig.accentBright).opacity(0.15))
                    )
                }
            }
        }
        .opacity(appeared ? 1 : 0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.25), value: appeared)
    }
}

// MARK: - Wrapping HStack (iOS 15 compatible)

struct WrappingHStack<Content: View>: View {
    let spacing: CGFloat
    let content: () -> Content
    
    init(spacing: CGFloat = 8, @ViewBuilder content: @escaping () -> Content) {
        self.spacing = spacing
        self.content = content
    }
    
    var body: some View {
        // Simple horizontal scroll as fallback for iOS 15
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: spacing) {
                content()
            }
        }
    }
}

// MARK: - Navigation Back Button

struct NavigationBackButton: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Button {
            presentationMode.wrappedValue.dismiss()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                Text("Back")
                    .font(.system(size: 17, weight: .regular))
            }
            .foregroundColor(ThemeColorsConfig.accentBright)
        }
    }
}
