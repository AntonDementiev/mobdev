import Foundation

final class CalculatorViewModel {

    var onStateChange: ((CalculatorState) -> Void)?

    private(set) var state: CalculatorState {
        didSet {
            guard state != oldValue else { return }
            store.save(state)
            onStateChange?(state)
        }
    }

    private let engine: ExpressionEvaluating
    private let store: StateStoring

    init(engine: ExpressionEvaluating = CalculatorEngine(),
         store: StateStoring = UserDefaultsStateStore()) {
        self.engine = engine
        self.store = store
        self.state = store.load() ?? CalculatorState()
    }


    func inputDigit(_ digit: Int) {
        update { s in
            s.startInput(continuing: false)
            s.expression += String(digit)
        }
    }

    func inputDecimalPoint() {
        update { s in
            s.startInput(continuing: false)
            if let last = s.expression.last, last.isNumber || last == "." {
                s.expression += "."
            } else {
                s.expression += "0."
            }
        }
    }

    func inputOperator(_ op: Operator) {
        update { s in
            s.startInput(continuing: true)
            s.expression.append(op.rawValue)
        }
    }

    func inputLeftParen() {
        update { s in
            s.startInput(continuing: false)
            s.expression += "("
        }
    }

    func inputRightParen() {
        update { s in
            s.startInput(continuing: true)
            s.expression += ")"
        }
    }

    func inputPercent() {
        update { s in
            s.startInput(continuing: true)
            s.expression += "%"
        }
    }

    func toggleSign() {
        update { s in
            s.startInput(continuing: true)
            s.expression = SignToggler.toggle(s.expression)
        }
    }

    func clear() {
        update { s in
            s.expression = ""
            s.error = nil
            s.justEvaluated = false
        }
    }

    func backspace() {
        update { s in
            s.error = nil
            s.justEvaluated = false
            if !s.expression.isEmpty { s.expression.removeLast() }
        }
    }

    func evaluate() {
        update { s in
            do {
                let value = try engine.evaluate(s.expression)
                let result = NumberFormatting.string(from: value)
                s.history.insert(HistoryItem(expression: s.expression, result: result), at: 0)
                if s.history.count > CalculatorState.historyLimit {
                    s.history.removeLast(s.history.count - CalculatorState.historyLimit)
                }
                s.expression = result
                s.lastResult = result
                s.error = nil
                s.justEvaluated = true
            } catch let error as CalculatorError {
                s.error = error
            } catch {
                s.error = .invalidNumber
            }
        }
    }


    func selectHistoryItem(at index: Int) {
        guard state.history.indices.contains(index) else { return }
        update { s in
            s.expression = s.history[index].expression
            s.error = nil
            s.justEvaluated = false
        }
    }

    func clearHistory() {
        update { $0.history.removeAll() }
    }


    func memoryAdd()      { applyToMemory(+) }
    func memorySubtract() { applyToMemory(-) }

    func memoryClear() {
        update { $0.memory = 0 }
    }

    func memoryRecall() {
        update { s in
            s.error = nil
            var value = NumberFormatting.string(from: s.memory)
            let canAppend = s.expression.last.map { "(+−×÷".contains($0) } ?? true
            if canAppend && !s.justEvaluated {
                if s.memory < 0, !s.expression.isEmpty { value = "(\(value))" }
                s.expression += value
            } else {
                s.expression = value
            }
            s.justEvaluated = false
        }
    }

    private func applyToMemory(_ operation: (Double, Double) -> Double) {
        update { s in
            let current: Double
            if s.expression.isEmpty {
                current = 0
            } else {
                do {
                    current = try engine.evaluate(s.expression)
                } catch let error as CalculatorError {
                    s.error = error
                    return
                } catch {
                    return
                }
            }
            s.memory = operation(s.memory, current)
            s.justEvaluated = true
        }
    }

    private func update(_ change: (inout CalculatorState) -> Void) {
        var copy = state
        change(&copy)
        state = copy
    }
}

private extension CalculatorState {
    mutating func startInput(continuing: Bool) {
        error = nil
        if justEvaluated && !continuing { expression = "" }
        justEvaluated = false
    }
}
