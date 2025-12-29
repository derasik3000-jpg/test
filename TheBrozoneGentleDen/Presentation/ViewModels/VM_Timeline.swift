import Foundation
import SwiftUI
import Combine
struct TimelineItemViewModel: Identifiable {
    let id: UUID
    let date: Date
    let sphereTitle: String
    let title: String
    let previewPhotoPath: String?
    let typeIcon: String
}

@MainActor
class TimelineViewModel: ObservableObject {
    @Published var items: [TimelineItemViewModel] = []
    @Published var selectedSphereId: UUID?
    @Published var rangeKind: ChronoTimeRange.TimeframeCategory = .month
    @Published var isLoading: Bool = false
    @Published var emptyStateVisible: Bool = false
    
    private let analyticsRepo: AuroraAnalyticsRepository
    
    init(analyticsRepo: AuroraAnalyticsRepository) {
        self.analyticsRepo = analyticsRepo
    }
    
    func loadTimelineItems() async {
        isLoading = true
        do {
            let range = buildTimelineTimeRange(for: rangeKind)
            let scope: AnalyticsScope = selectedSphereId != nil ? .sphere(selectedSphereId!) : .global
            let timeline = try await analyticsRepo.computeTimelineDataset(range: range, scope: scope)
            
            items = timeline.items.map { item in
                let icon: String
                switch item.type {
                case .beforeAfterCompleted:
                    icon = "checkmark.circle.fill"
                case .beforeOnly:
                    icon = "photo"
                case .stagesUpdate:
                    icon = "square.stack.3d.up"
                case .milestone:
                    icon = "flag.fill"
                }
                
                return TimelineItemViewModel(
                    id: item.id,
                    date: item.date,
                    sphereTitle: item.sphereTitle,
                    title: item.title ?? "Progress Update",
                    previewPhotoPath: item.previewPhotoPath,
                    typeIcon: icon
                )
            }
            
            emptyStateVisible = items.isEmpty
        } catch {
            emptyStateVisible = true
        }
        isLoading = false
    }
    
    func applyTimelineFiltersAndReload() async {
        await loadTimelineItems()
    }
    
    private func buildTimelineTimeRange(for kind: ChronoTimeRange.TimeframeCategory) -> ChronoTimeRange {
        let calendar = Calendar.current
        let now = Date()
        
        switch kind {
        case .week:
            let start = calendar.date(byAdding: .day, value: -7, to: now) ?? now
            return ChronoTimeRange(kind: kind, start: start, end: now)
        case .month:
            let start = calendar.date(byAdding: .month, value: -1, to: now) ?? now
            return ChronoTimeRange(kind: kind, start: start, end: now)
        case .last90Days:
            let start = calendar.date(byAdding: .day, value: -90, to: now) ?? now
            return ChronoTimeRange(kind: kind, start: start, end: now)
        case .custom(let start, let end):
            return ChronoTimeRange(kind: kind, start: start, end: end)
        }
    }
}

