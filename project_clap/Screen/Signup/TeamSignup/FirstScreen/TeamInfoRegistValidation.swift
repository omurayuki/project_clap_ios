import Foundation

enum TeamInfoRegistValidationResult {
    case ok
    case empty
    case lessThanText
}

extension TeamInfoRegistValidationResult {
    var isValid: Bool {
        switch self {
        case .ok:
            return true
        default:
            return false
        }
    }
}

struct TeamInfoRegistValidation {
    static func validate(teamId: String) -> TeamInfoRegistValidationResult {
        guard teamId.count >= 10 else {
            return .lessThanText
        }
        return .ok
    }
    
    static func validatePicker(position: String, year: String) -> TeamInfoRegistValidationResult {
        guard position != R.string.locarizable.empty() && year != R.string.locarizable.empty() else {
            return .empty
        }
        return .ok
    }
}