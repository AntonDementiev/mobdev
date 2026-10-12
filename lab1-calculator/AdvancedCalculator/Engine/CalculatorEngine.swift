import Foundation

protocol ExpressionEvaluating {
    func evaluate(_ expression: String) throws -> Double
}

struct CalculatorEngine: ExpressionEvaluating {
    private let tokenizer = Tokenizer()
    private let validator = ExpressionValidator()

    /// "(12+5)×3" -> 51. Бросает `CalculatorError` при некорректном выражении.
    func evaluate(_ expression: String) throws -> Double {
        let trimmed = expression.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { throw CalculatorError.emptyExpression }

        let tokens = try tokenizer.tokenize(trimmed)
        try validator.validate(tokens)
        var parser = ExpressionParser(tokens: tokens)
        let result = try parser.parse()

        guard result.isFinite else { throw CalculatorError.overflow }
        return result
    }

    func evaluateResult(_ expression: String) -> Result<Double, CalculatorError> {
        do {
            return .success(try evaluate(expression))
        } catch let error as CalculatorError {
            return .failure(error)
        } catch {
            return .failure(.invalidNumber)
        }
    }
}
