import Foundation

public enum FeatureBucket: String {
    case pain
    case mechanics
    case swellingROM
    case duration
    case mitigating
}

public struct FeatureChunk: Identifiable, Hashable {
    public let id: UUID
    public let bucket: FeatureBucket
    public let weight: Int
    
    public init(id: UUID = UUID(), bucket: FeatureBucket, weight: Int) {
        self.id = id
        self.bucket = bucket
        self.weight = weight
    }
}

public struct FeatureStackedModel {
    public let score: Int
    public let chunks: [FeatureChunk]
    
    public init(score: Int, chunks: [FeatureChunk]) {
        self.score = score
        self.chunks = chunks
    }
}

