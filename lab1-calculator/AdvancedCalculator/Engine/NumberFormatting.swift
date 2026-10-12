import Foundation

enum NumberFormatting {

    private static let formatter: NumberFormatter = {
        let f = NumberFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.numberStyle = .decimal
        f.usesGroupingSeparator = false
        f.minimumFractionDigits = 0
        f.maximumFractionDigits = 10
        return f
    }()

    static func string(from value: Double) -> String {
        let text = formatter.string(from: NSNumber(value: value)) ?? String(value)
        if text == "-0" { return "0" }
        return text.replacingOccurrences(of: "-", with: String(Operator.minus.rawValue))
    }
}
