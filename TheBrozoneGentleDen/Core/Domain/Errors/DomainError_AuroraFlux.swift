import Foundation

enum AuroraFluxError: Error {
    case notFound
    case validationFailed(String)
    case storageError(String)
    case photoAccessDenied
    case unsupportedOperation
}

