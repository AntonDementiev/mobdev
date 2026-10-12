import Foundation

struct HistoryItem: Codable, Equatable {
    let expression: String
    let result: String
}

struct CalculatorState: Codable, Equatable {
    static let historyLimit = 10

    var expression: String = ""
    var history: [HistoryItem] = []
    var memory: Double = 0
    var lastResult: String?
    var error: CalculatorError?
    var justEvaluated = false            

    var hasMemory: Bool { memory != 0 }
}
