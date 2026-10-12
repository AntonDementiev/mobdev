import Foundation

struct Tokenizer {

    func tokenize(_ input: String) throws -> [Token] {
        var tokens: [Token] = []
        let chars = Array(input)
        var i = 0

        while i < chars.count {
            let c = chars[i]

            if c.isWhitespace {
                i += 1
                continue
            }

            if c.isNumber || c == "." {
                var literal = ""
                while i < chars.count, chars[i].isNumber || chars[i] == "." {
                    literal.append(chars[i])
                    i += 1
                }
                tokens.append(.number(try parseNumber(literal)))
                continue
            }

            if let op = Operator(symbol: c) {
                tokens.append(.op(op))
            } else {
                switch c {
                case "(": tokens.append(.leftParen)
                case ")": tokens.append(.rightParen)
                case "%": tokens.append(.percent)
                default:  throw CalculatorError.invalidCharacter(String(c))
                }
            }
            i += 1
        }
        return tokens
    }

    private func parseNumber(_ literal: String) throws -> Double {
        let points = literal.filter { $0 == "." }.count
        guard points <= 1 else { throw CalculatorError.multipleDecimalPoints }
        guard let value = Double(literal) else { throw CalculatorError.invalidNumber }
        return value
    }
}
