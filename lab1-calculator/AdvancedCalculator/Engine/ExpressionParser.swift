import Foundation

/// Шаг 3: рекурсивный спуск — вычисляет выражение с учётом приоритета
///
///     expression = term   { ("+" | "−") term }
///     term       = factor { ("×" | "÷") factor }
///     factor     = "−" factor | primary { "%" }
///     primary    = number | "(" expression ")"
struct ExpressionParser {
    private let tokens: [Token]
    private var position = 0

    init(tokens: [Token]) {
        self.tokens = tokens
    }

    /// `mutating`, потому что struct меняет своё свойство `position`.
    mutating func parse() throws -> Double {
        let value = try parseExpression()
        guard position == tokens.count else { throw CalculatorError.missingOperator }
        return value
    }


    private mutating func parseExpression() throws -> Double {
        var value = try parseTerm()
        while let op = peekOperator(), op.precedence == 1 {
            position += 1
            let rhs = try parseTerm()
            value = (op == .plus) ? value + rhs : value - rhs
        }
        return value
    }

    private mutating func parseTerm() throws -> Double {
        var value = try parseFactor()
        while let op = peekOperator(), op.precedence == 2 {
            position += 1
            let rhs = try parseFactor()
            if op == .divide {
                guard rhs != 0 else { throw CalculatorError.divisionByZero }
                value /= rhs
            } else {
                value *= rhs
            }
        }
        return value
    }

    private mutating func parseFactor() throws -> Double {
        if peekOperator() == .minus {
            position += 1
            return -(try parseFactor())
        }
        var value = try parsePrimary()
        while peek() == .percent {
            position += 1
            value /= 100
        }
        return value
    }

    private mutating func parsePrimary() throws -> Double {
        switch peek() {
        case .number(let value):
            position += 1
            return value
        case .leftParen:
            position += 1
            let value = try parseExpression()
            guard peek() == .rightParen else { throw CalculatorError.mismatchedParentheses }
            position += 1
            return value
        default:
            throw CalculatorError.missingOperand
        }
    }

    private func peek() -> Token? {
        position < tokens.count ? tokens[position] : nil
    }

    private func peekOperator() -> Operator? {
        if case .op(let op) = peek() { return op }
        return nil
    }
}
