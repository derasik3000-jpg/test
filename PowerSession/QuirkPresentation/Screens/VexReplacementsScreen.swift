import SwiftUI

public struct VexReplacementsScreen: View {
    @StateObject private var plinthVM: MurkyCatalogViewModel
    @State private var quellSelectedReplacement: FizzReplacementModel?
    @State private var vexShowDetail = false
    
    public init(plinthVM: MurkyCatalogViewModel) {
        _plinthVM = StateObject(wrappedValue: plinthVM)
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                SternGradientBackground()
                
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 12) {
                            Text("Replacements")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundColor(VexColorPalette.quellAccent)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 16)
                                .padding(.top, 8)
                            
                            TextField("Search stadium, intervals, run...", text: $plinthVM.quellQuery)
                                .textFieldStyle(.plain)
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(VexColorPalette.fizzGlassCard)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(VexColorPalette.vexGlassBorder, lineWidth: 1)
                                        )
                                )
                                .foregroundColor(VexColorPalette.wharfTextPrimary)
                                .onChange(of: plinthVM.quellQuery) { _ in
                                    plinthVM.brindleReload()
                                }
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(VexGoalTag.allCases) { tag in
                                        WharfGoalTagChip(
                                            quirkTag: tag,
                                            vexIsSelected: plinthVM.vexSelectedTags.contains(tag)
                                        ) {
                                            if plinthVM.vexSelectedTags.contains(tag) {
                                                plinthVM.vexSelectedTags.remove(tag)
                                            } else {
                                                plinthVM.vexSelectedTags.insert(tag)
                                            }
                                            plinthVM.fizzSaveFilters()
                                            plinthVM.brindleReload()
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                            
                            Picker("Scope", selection: $plinthVM.tarnScope) {
                                Text("All").tag(BrindleSearchScope.all)
                                Text("Favorites").tag(BrindleSearchScope.favorites)
                                Text("Recent").tag(BrindleSearchScope.recent)
                            }
                            .pickerStyle(.segmented)
                            .onChange(of: plinthVM.tarnScope) { _ in
                                plinthVM.brindleReload()
                            }
                            
                            if plinthVM.wharfIsLoading {
                                ProgressView()
                                    .tint(VexColorPalette.quellAccent)
                                    .padding(.top, 40)
                            } else if plinthVM.fizzItems.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "magnifyingglass")
                                        .font(.system(size: 40))
                                        .foregroundColor(VexColorPalette.wharfTextSecondary)
                                    
                                    Text("No replacements found")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(VexColorPalette.wharfTextSecondary)
                                }
                                .padding(.top, 60)
                            } else {
                                LazyVStack(spacing: 12) {
                                    ForEach(plinthVM.fizzItems) { replacement in
                        PlinthReplacementCard(
                            brindleReplacement: replacement,
                            quellOnTap: {
                                quellSelectedReplacement = replacement
                                vexShowDetail = true
                            },
                            vexOnFavorite: {
                                plinthVM.tarnToggleFavorite(replacement.id)
                            }
                        )
                                    }
                                }
                            }
                        }
                        .padding(16)
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .onAppear {
                plinthVM.quellRestoreFilters()
                plinthVM.brindleReload()
            }
            .murkyCustomSheet(isPresented: $vexShowDetail) {
                if let replacement = quellSelectedReplacement {
                    QuirkDetailSheet(replacement: replacement, onApplied: {
                        vexShowDetail = false
                        plinthVM.brindleReload()
                    })
                }
            }
        }
    }
}

