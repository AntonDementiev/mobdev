import Foundation

/// `Error` — чтобы можно было делать `throw`, `Codable` — чтобы сохранять состояние ошибки.
enum CalculatorError: Error, Equatable, Codable {
    case emptyExpression
    case divisionByZero
    case mismatchedParentheses
    case consecutiveOperators
    case multipleDecimalPoints
    case trailingOperator
    case missingOperand
    case missingOperator
    case invalidNumber
    case invalidCharacter(String)
    case overflow                 

    var message: String {
        switch self {
        case .emptyExpression:       return "Введите выражение"
        case .divisionByZero:        return "Деление на ноль"
        case .mismatchedParentheses: return "Неправильные скобки"
        case .consecutiveOperators:  return "Два оператора подряд"
        case .multipleDecimalPoints: return "Несколько точек в числе"
        case .trailingOperator:      return "Выражение кончается оператором"
        case .missingOperand:        return "Не хватает числа"
        case .missingOperator:       return "Не хватает оператора"
        case .invalidNumber:         return "Некорректное число"
        case .invalidCharacter(let c): return "Неизвестный символ «\(c)»"
        case .overflow:              return "Слишком большое число"
        }
    }
}

extension CalculatorError: LocalizedError {
    var errorDescription: String? { message }
}
