import Foundation
import CoreData

public class ArticleRepositoryImpl: ArticleRepository {
    private let stack: PersistenceStackController
    
    public init(stack: PersistenceStackController = .shared) {
        self.stack = stack
        seedArticlesIfNeeded()
    }
    
    public func all() -> [ArticleDTO] {
        let context = stack.context
        let request: NSFetchRequest<Article> = Article.requestMaterialization()
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        guard let results = try? context.fetch(request) else {
            return []
        }
        
        return results.map { $0.toDTO() }
    }
    
    public func bySlug(_ slug: String) -> ArticleDTO? {
        let context = stack.context
        let request: NSFetchRequest<Article> = Article.requestMaterialization()
        request.predicate = NSPredicate(format: "slug == %@", slug)
        
        guard let entity = try? context.fetch(request).first else {
            return nil
        }
        
        return entity.toDTO()
    }
    
    public func search(_ query: String) -> [ArticleDTO] {
        let context = stack.context
        let request: NSFetchRequest<Article> = Article.requestMaterialization()
        
        let titlePredicate = NSPredicate(format: "title CONTAINS[cd] %@", query)
        request.predicate = titlePredicate
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        guard let results = try? context.fetch(request) else {
            return []
        }
        
        return results.map { $0.toDTO() }
    }
    
    private func seedArticlesIfNeeded() {
        let context = stack.context
        let request: NSFetchRequest<Article> = Article.requestMaterialization()
        let count = (try? context.count(for: request)) ?? 0
        
        if count == 0 {
            createDefaultArticles()
        }
    }
    
    private func createDefaultArticles() {
        let articles = getDefaultArticles()
        
        for dto in articles {
            let entity = Article(context: stack.context)
            entity.updateFrom(dto: dto)
        }
        
        stack.save()
    }
    
    private func getDefaultArticles() -> [ArticleDTO] {
        return [
            ArticleDTO(
                slug: "what-is-doms",
                title: "What is DOMS?",
                body: """
                Delayed Onset Muscle Soreness (DOMS) is a normal response to exercise, especially after new or intense activities.
                
                Key Characteristics:
                • Appears 24-72 hours after exercise
                • Peak soreness typically at 48 hours
                • Dull, aching muscle pain
                • Affects both sides symmetrically
                • Temporary stiffness and tenderness
                • Reduced range of motion
                
                What Causes DOMS?
                DOMS results from microscopic damage to muscle fibers during exercise, particularly eccentric (lengthening) movements. This is a normal part of muscle adaptation and growth.
                
                Management:
                • Light activity promotes recovery
                • Gentle stretching may help
                • Adequate rest between sessions
                • Gradual progression in training
                • Proper nutrition and hydration
                
                When to Worry:
                DOMS should improve within 3-5 days. If pain persists beyond a week, is severe, or includes swelling, consult a healthcare provider.
                
                Remember: Some muscle soreness after exercise is normal and even beneficial. It's part of getting stronger. This app helps you distinguish normal DOMS from injury warning signs.
                
                Source: This information is based on current sports medicine guidelines. For detailed medical information, please consult the Harvard Health resource linked below.
                """,
                tags: ["doms", "education", "muscle", "harvard"],
                externalURL: "https://www.health.harvard.edu/staying-healthy/core-workout-can-cause-muscle-soreness"
            ),
            ArticleDTO(
                slug: "rice-safe-application",
                title: "RICE: How to Apply Safely",
                body: """
                RICE (Rest, Ice, Compression, Elevation) is a well-established first-aid protocol for acute soft tissue injuries. Here's how to use it safely and effectively.
                
                REST
                • Avoid activities that cause pain
                • Don't mean complete immobilization
                • Gentle, pain-free movement is beneficial
                • Listen to your body's signals
                
                ICE
                • Apply within first 48-72 hours
                • Duration: 10-15 minutes at a time
                • Frequency: 2-3 times daily
                • Never apply ice directly to skin
                • Use a thin towel as barrier
                • Stop if skin becomes numb
                
                COMPRESSION
                • Use elastic bandage
                • Should be snug, not tight
                • Check circulation regularly
                • Loosen if numbness/tingling occurs
                • Remove at night unless advised otherwise
                
                ELEVATION
                • Raise injured area above heart level
                • Especially effective when resting
                • Reduces swelling
                • Combine with ice for best results
                
                Safety Warnings:
                • Never apply ice for more than 20 minutes
                • Don't use heat in first 48-72 hours
                • If pain/swelling worsens, seek medical care
                • Not a substitute for professional diagnosis
                
                When to See a Doctor:
                • Severe pain or inability to bear weight
                • Significant swelling within 1-2 hours
                • No improvement after 48-72 hours
                • Suspected fracture or severe strain
                
                Modern Note: Some experts now recommend PEACE & LOVE protocol, which emphasizes active recovery after the initial acute phase.
                
                Source: Based on current sports medicine protocols. See Harvard Health resources below for physician-reviewed information on muscle strains and recovery.
                """,
                tags: ["rice", "acute", "treatment", "safety", "harvard"],
                externalURL: "https://www.health.harvard.edu/staying-healthy/best-ways-to-recover-from-a-muscle-strain"
            ),
            ArticleDTO(
                slug: "ice-or-heat",
                title: "Ice or Heat? Safe Application Guide",
                body: """
                Knowing when to use ice versus heat can significantly impact your recovery. Here's a science-based guide to using both safely and effectively.
                
                WHEN TO USE ICE (Cold Therapy)
                Best for:
                • Acute injuries (first 48-72 hours)
                • Fresh swelling or inflammation
                • Sharp, immediate pain
                • After intense workouts
                
                How to Apply Safely:
                • Duration: 10-15 minutes
                • Frequency: Every 2-3 hours during first 48 hours
                • Always use barrier (towel/cloth)
                • Never apply directly to skin
                • Stop if skin becomes numb or white
                
                Benefits:
                • Reduces inflammation
                • Numbs pain
                • Decreases swelling
                • Slows tissue metabolism
                
                WHEN TO USE HEAT
                Best for:
                • Chronic conditions (lasting weeks/months)
                • Muscle stiffness and tension
                • Before exercise (to warm muscles)
                • After acute phase has passed (72+ hours)
                
                How to Apply Safely:
                • Duration: 15-20 minutes
                • Temperature: Warm, not burning hot
                • Use heating pad or warm towel
                • Never sleep with heating pad on
                • Check skin regularly
                
                Benefits:
                • Increases blood flow
                • Relaxes tight muscles
                • Improves flexibility
                • Reduces chronic pain
                
                SAFETY WARNINGS
                Never Use Ice:
                • On open wounds
                • If you have circulation problems
                • Before athletic activity
                • For more than 20 minutes at once
                
                Never Use Heat:
                • On acute injuries (first 48-72 hours)
                • On fresh swelling
                • If area is already inflamed
                • On open wounds or infections
                
                Contrast Therapy:
                Some people alternate ice and heat (after acute phase). Consult healthcare provider before trying this approach.
                
                When to See a Doctor:
                • Symptoms don't improve after 3-5 days
                • Pain worsens despite treatment
                • Swelling increases
                • You're unsure which to use
                
                Remember: These are general guidelines. Individual conditions may require different approaches. Always consult a healthcare provider for persistent or severe symptoms.
                
                Source: Information based on current pain management guidelines. See Harvard Health article below for physician-reviewed guidance on cold and heat therapy.
                """,
                tags: ["ice", "heat", "treatment", "safety", "harvard"],
                externalURL: "https://www.health.harvard.edu/pain/cold-versus-heat-for-pain-relief-how-to-use-them-safely-and-effectively"
            ),
            ArticleDTO(
                slug: "red-flags-back-pain",
                title: "Red Flags: Back Pain Warning Signs",
                body: """
                Most back pain improves with time and conservative care, but certain symptoms require immediate medical attention.
                
                SEEK IMMEDIATE MEDICAL CARE IF:
                
                Neurological Red Flags:
                • Numbness in groin or inner thighs (saddle anesthesia)
                • Loss of bladder or bowel control
                • Progressive leg weakness
                • Numbness in both legs
                • Difficulty walking or standing
                
                These may indicate cauda equina syndrome - a medical emergency requiring immediate intervention.
                
                Serious Underlying Conditions:
                • Severe pain after trauma or fall
                • Pain with fever or unexplained weight loss
                • History of cancer and new back pain
                • Severe pain that worsens when lying down
                • Pain that doesn't improve with rest
                • Age over 50 with new severe back pain
                • Recent infection
                • Use of steroids or immunosuppressive drugs
                
                Pain Patterns That Need Evaluation:
                • Constant, severe pain (not relieved by position change)
                • Night pain that wakes you from sleep
                • Pain radiating down both legs
                • Pain accompanied by chest pain or shortness of breath
                • Progressive worsening over days/weeks
                
                WHEN TO SEE A DOCTOR (Non-Emergency):
                • Pain lasting more than 4-6 weeks
                • Moderate leg pain or numbness
                • Pain interfering with daily activities
                • Previous back surgery
                • Pain not responding to conservative care
                
                GENERAL BACK PAIN MANAGEMENT:
                For non-red-flag back pain:
                • Stay active - bed rest is not recommended
                • Gentle movement and walking
                • Over-the-counter pain relief as needed
                • Ice or heat (see our Ice vs Heat article)
                • Gradual return to normal activities
                • Core strengthening exercises
                
                Prevention Strategies:
                • Maintain healthy weight
                • Regular exercise and core strengthening
                • Proper lifting technique
                • Good posture throughout day
                • Avoid prolonged sitting
                • Stretch regularly
                
                Important: This app is a screening tool, NOT a diagnostic tool. When in doubt, consult a healthcare provider. Back pain with red flags requires professional medical evaluation.
                
                Most back pain is mechanical and improves with time. However, don't delay seeking care if you experience any red flag symptoms.
                
                Source: Based on clinical guidelines for back pain assessment. See Harvard Health article below for comprehensive, physician-reviewed information on managing back pain.
                """,
                tags: ["back", "redflag", "urgent", "spine", "harvard"],
                externalURL: "https://www.health.harvard.edu/pain/managing-back-pain"
            )
        ]
    }
}
