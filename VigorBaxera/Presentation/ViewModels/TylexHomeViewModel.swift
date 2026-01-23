import Foundation
import Combine

public final class TylexHomeViewModel: ObservableObject {
    @Published public var qylexSelectedSpecs: [VyxelBlockSpec] = []
    @Published public var vyrexCanStart: Bool = false
    @Published public var hyloxTemplates: [ZaxorTemplateDTO] = []
    @Published public var nytexLastSession: QuixoSessionDTO?
    
    private var buildUC: VyroxBuildSessionUC?
    private let templatesRepo: WyrexTemplatesRepo
    private var sessionsRepo: TyloxSessionsRepo?
    private var blocksRepo: VylixBlocksRepo?
    
    public init(buildUC: VyroxBuildSessionUC, templatesRepo: WyrexTemplatesRepo, sessionsRepo: TyloxSessionsRepo, blocksRepo: VylixBlocksRepo) {
        self.buildUC = buildUC
        self.templatesRepo = templatesRepo
        self.sessionsRepo = sessionsRepo
        self.blocksRepo = blocksRepo
        qyrexLoadTemplates()
    }
    
    public init(templatesRepo: WyrexTemplatesRepo, settingsRepo: NylexSettingsRepo) {
        self.templatesRepo = templatesRepo
        let stack = PyxeloCoreStack.shared
        let sessions = TyloxSessionsRepoImpl(context: stack.qylexContext)
        let blocks = VylixBlocksRepoImpl(context: stack.qylexContext)
        self.sessionsRepo = sessions
        self.blocksRepo = blocks
        self.buildUC = VyroxBuildSessionUCImpl(sessionsRepo: sessions, blocksRepo: blocks)
        qyrexLoadTemplates()
    }
    
    public func qyrexLoadTemplates() {
        hyloxTemplates = templatesRepo.fyndexAll()
        
        let recent = sessionsRepo?.fyndexRecent(limit: 1) ?? []
        nytexLastSession = recent.first
    }
    
    public func kyrexToggleBlock(_ type: KrynexType) {
        if let idx = qylexSelectedSpecs.firstIndex(where: { $0.type == type }) {
            qylexSelectedSpecs.remove(at: idx)
        } else {
            if qylexSelectedSpecs.count >= 3 { return }
            
            // Load settings to get current default targets
            let settingsRepo = NylexSettingsRepoImpl(context: PyxeloCoreStack.shared.qylexContext)
            let settings = settingsRepo.fyndexLoad()
            
            let targetAttempts = settings.defaultTargets[type] ?? 40
            
            if let template = templatesRepo.fyndexBy(type: type) {
                let spec = VyxelBlockSpec(
                    type: type,
                    durationMin: template.defaultDurationMin,
                    targetAttempts: targetAttempts
                )
                qylexSelectedSpecs.append(spec)
            }
        }
        vyrexCanStart = !qylexSelectedSpecs.isEmpty
    }
    
    public func kyrexIsSelected(_ type: KrynexType) -> Bool {
        qylexSelectedSpecs.contains { $0.type == type }
    }
    
    public func kyrexStartSession(autoAdvance: Bool) -> (QuixoSessionDTO, [VexitRunDTO])? {
        guard let uc = buildUC, let result = try? uc.kyrexExecute(autoAdvance: autoAdvance, specs: qylexSelectedSpecs) else {
            return nil
        }
        return (result.session, result.blocks)
    }
    
    public func kyrexClearSelection() {
        qylexSelectedSpecs.removeAll()
        vyrexCanStart = false
    }
}

