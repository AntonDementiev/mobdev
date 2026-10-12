import Foundation

enum Operator: Character, CaseIterable, Codable {
    case plus = "+"
    case minus = "−"
    case multiply = "×"
    case divide = "÷"

    var precedence: Int {
        switch self {
        case .plus, .minus:       return 1
        case .multiply, .divide:  return 2
        }
    }

    init?(symbol: Character) {
        switch symbol {
        case "+":       self = .plus
        case "−", "-":  self = .minus
        case "×", "*":  self = .multiply
        case "÷", "/":  self = .divide
        default:        return nil
        }
    }
}

enum Token: Equatable {
    case number(Double)
    case op(Operator)
    case leftParen
    case rightParen
    case percent
}
