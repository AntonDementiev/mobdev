import Foundation

struct ExpressionValidator {

    func validate(_ tokens: [Token]) throws {
        guard !tokens.isEmpty else { throw CalculatorError.emptyExpression }

        var depth = 0
        var previous: Token?

        for token in tokens {
            switch token {
            case .number:
                if endsOperand(previous) { throw CalculatorError.missingOperator }

            case .leftParen:
                if endsOperand(previous) { throw CalculatorError.missingOperator }
                depth += 1

            case .rightParen:
                depth -= 1
                if depth < 0 { throw CalculatorError.mismatchedParentheses }
                if case .op = previous { throw CalculatorError.missingOperand }
                if previous == .leftParen { throw CalculatorError.missingOperand }

            case .op(let op):
                if case .op = previous { throw CalculatorError.consecutiveOperators }
                if previous == nil || previous == .leftParen, op != .minus {
                    throw CalculatorError.missingOperand
                }

            case .percent:
                if !endsOperand(previous) { throw CalculatorError.missingOperand }
            }
            previous = token
        }

        if case .op = previous { throw CalculatorError.trailingOperator }
        if depth != 0 { throw CalculatorError.mismatchedParentheses }
    }

    private func endsOperand(_ token: Token?) -> Bool {
        switch token {
        case .number, .rightParen, .percent: return true
        default:                             return false
        }
    }
}
