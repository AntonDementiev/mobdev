import Foundation

enum SignToggler {
    private static let minus = String(Operator.minus.rawValue)

    static func toggle(_ expression: String) -> String {
        if let range = expression.range(of: #"\(−[0-9.]+%*\)$"#, options: .regularExpression) {
            let inner = expression[range].dropFirst(2).dropLast()
            return expression.replacingCharacters(in: range, with: inner)
        }

        if let range = expression.range(of: #"[0-9.]+%*$"#, options: .regularExpression) {
            let number = expression[range]
            let prefix = expression[..<range.lowerBound]
            
            if prefix == minus || prefix.hasSuffix("(" + minus) {
                return String(prefix.dropLast()) + number
            }
            return String(prefix) + "(" + minus + number + ")"
        }

        if expression.hasSuffix(")"), let open = matchingOpenParen(in: expression) {
            let group = expression[open...]
            return String(expression[..<open]) + "(" + minus + group + ")"
        }

        guard let last = expression.last else { return minus }
        if last == "(" { return expression + minus }
        if Operator(symbol: last) != nil { return expression + "(" + minus }
        return expression
    }

    private static func matchingOpenParen(in expression: String) -> String.Index? {
        var depth = 0
        var index = expression.endIndex
        while index > expression.startIndex {
            index = expression.index(before: index)
            switch expression[index] {
            case ")": depth += 1
            case "(":
                depth -= 1
                if depth == 0 { return index }
            default: break
            }
        }
        return nil
    }
}
