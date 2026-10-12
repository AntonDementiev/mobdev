import UIKit

enum CalculatorKey {
    case digit(Int)
    case op(Operator)
    case point, leftParen, rightParen
    case clear, backspace, percent, toggleSign, equals
    case memoryClear, memoryRecall, memoryAdd, memorySubtract

    var title: String {
        switch self {
        case .digit(let d):   return String(d)
        case .op(let op):     return String(op.rawValue)
        case .point:          return "."
        case .leftParen:      return "("
        case .rightParen:     return ")"
        case .clear:          return "C"
        case .backspace:      return "⌫"
        case .percent:        return "%"
        case .toggleSign:     return "±"
        case .equals:         return "="
        case .memoryClear:    return "MC"
        case .memoryRecall:   return "MR"
        case .memoryAdd:      return "M+"
        case .memorySubtract: return "M−"
        }
    }

    var backgroundColor: UIColor {
        switch self {
        case .digit, .point, .toggleSign:
            return .secondarySystemBackground
        case .op, .equals:
            return .systemOrange
        case .memoryClear, .memoryRecall, .memoryAdd, .memorySubtract:
            return .tertiarySystemFill
        default:
            return .systemGray4
        }
    }

    var titleColor: UIColor {
        switch self {
        case .op, .equals: return .white
        default:           return .label
        }
    }
}
