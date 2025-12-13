import SwiftUI

struct GamingTabBarView: View {
    @State private var selectedTab: Int = 0
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    
    // View models создаются один раз и сохраняются
    @StateObject private var spawnViewModel: GamingSpawnViewModel
    @StateObject private var profileViewModel: GamingProfileViewModel
    @StateObject private var ideasViewModel: GamingIdeasViewModel
    @StateObject private var gamesViewModel: GamingGamesViewModel
    @StateObject private var calendarViewModel: GamingCalendarViewModel
    
    init() {
        let recordRepository = GamingRecordRepository()
        let programRepository = GamingProgramRepository()
        let planRepository = GamingPlanRepository()
        let markRepository = GamingMarkRepository()
        let preferenceRepository = GamingPreferenceRepository()
        let notificationService = GamingNotificationService()
        let pointsCalculator = GamingPointsCalculator(markRepository: markRepository)
        
        _spawnViewModel = StateObject(wrappedValue: GamingSpawnViewModel(
            recordRepository: recordRepository,
            programRepository: programRepository,
            markRepository: markRepository,
            pointsCalculator: pointsCalculator
        ))
        _profileViewModel = StateObject(wrappedValue: GamingProfileViewModel(
            preferenceRepository: preferenceRepository,
            pointsCalculator: pointsCalculator,
            recordRepository: recordRepository,
            programRepository: programRepository
        ))
        _ideasViewModel = StateObject(wrappedValue: GamingIdeasViewModel(
            repository: recordRepository,
            addUseCase: AddGamingRecordUseCase(repository: recordRepository),
            pointsCalculator: pointsCalculator
        ))
        _gamesViewModel = StateObject(wrappedValue: GamingGamesViewModel(
            repository: programRepository,
            addUseCase: AddGamingProgramUseCase(repository: programRepository),
            markRepository: markRepository,
            pointsCalculator: pointsCalculator
        ))
        _calendarViewModel = StateObject(wrappedValue: GamingCalendarViewModel(
            planRepository: planRepository,
            addUseCase: AddGamingPlanUseCase(
                planRepository: planRepository,
                notificationService: notificationService
            ),
            programRepository: programRepository,
            recordRepository: recordRepository
        ))
    }
    
    var body: some View {
        Group {
            if hasCompletedOnboarding {
                ZStack(alignment: .bottom) {
                    // Общий фон для всех табов - создается один раз
                    GamingGradientBackgroundView()
                    
                    ZStack {
                        GamingSpawnView(
                            viewModel: spawnViewModel,
                            profileViewModel: profileViewModel,
                            ideasViewModel: ideasViewModel
                        )
                        .opacity(selectedTab == 0 ? 1 : 0)
                        .allowsHitTesting(selectedTab == 0)
                        
                        GamingIdeasView(viewModel: ideasViewModel)
                            .opacity(selectedTab == 1 ? 1 : 0)
                            .allowsHitTesting(selectedTab == 1)
                        
                        GamingGamesView(viewModel: gamesViewModel)
                            .opacity(selectedTab == 2 ? 1 : 0)
                            .allowsHitTesting(selectedTab == 2)
                        
                        GamingCalendarView(viewModel: calendarViewModel)
                            .opacity(selectedTab == 3 ? 1 : 0)
                            .allowsHitTesting(selectedTab == 3)
                        
                        GamingProfileView(viewModel: profileViewModel)
                            .opacity(selectedTab == 4 ? 1 : 0)
                            .allowsHitTesting(selectedTab == 4)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea(.keyboard, edges: .bottom)
                    
                    GamingCustomTabBar(selectedTab: $selectedTab)
                        .padding(.bottom, 8)
                }
                .ignoresSafeArea(.keyboard, edges: .bottom)
                .onChange(of: selectedTab) { newTab in
                    // Обновляем данные при переключении на определенный таб
                    switch newTab {
                    case 0:
                        spawnViewModel.loadData()
                    case 1:
                        ideasViewModel.loadRecords()
                    case 2:
                        gamesViewModel.loadPrograms()
                    case 4:
                        profileViewModel.loadData()
                    default:
                        break
                    }
                }
            } else {
                GamingOnboardingView(isComplete: $hasCompletedOnboarding)
                    .onChange(of: hasCompletedOnboarding) { newValue in
                        if newValue {
                            let notificationService = GamingNotificationService()
                            Task {
                                _ = await notificationService.requestAuthorization()
                            }
                        }
                    }
            }
        }
    }
}
