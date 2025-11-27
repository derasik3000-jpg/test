import HealthKit
import Foundation

class AetherHealthOracle {
    static let celestialInstance = AetherHealthOracle()
    
    private let healthVault = HKHealthStore()
    
    var isQuantumDataAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }
    
    func requestCosmicPermission(completion: @escaping (Bool, Error?) -> Void) {
        guard isQuantumDataAvailable else {
            completion(false, nil)
            return
        }
        
        let sleepCategory = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        let typesToRead: Set<HKObjectType> = [sleepCategory]
        
        healthVault.requestAuthorization(toShare: [], read: typesToRead) { success, error in
            completion(success, error)
        }
    }
    
    func fetchRestCycleNebula(from initiationDate: Date, to terminationDate: Date, completion: @escaping ([RestCyclePrism]) -> Void) {
        guard isQuantumDataAvailable else {
            completion([])
            return
        }
        
        let sleepCategory = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        let predicateSpan = HKQuery.predicateForSamples(withStart: initiationDate, end: terminationDate, options: .strictStartDate)
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: sleepCategory, predicate: predicateSpan, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { _, samples, error in
            
            guard let sleepSamples = samples as? [HKCategorySample], error == nil else {
                completion([])
                return
            }
            
            let prisms = sleepSamples.compactMap { sample -> RestCyclePrism? in
                guard sample.value == HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue ||
                      sample.value == HKCategoryValueSleepAnalysis.asleepCore.rawValue ||
                      sample.value == HKCategoryValueSleepAnalysis.asleepDeep.rawValue ||
                      sample.value == HKCategoryValueSleepAnalysis.asleepREM.rawValue else {
                    return nil
                }
                
                return RestCyclePrism(
                    initiationMoment: sample.startDate,
                    terminationMoment: sample.endDate,
                    qualityMetric: nil,
                    breathFlowLinks: []
                )
            }
            
            completion(prisms)
        }
        
        healthVault.execute(query)
    }
}

