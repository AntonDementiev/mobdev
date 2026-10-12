import Foundation

protocol StateStoring {
    func load() -> CalculatorState?
    func save(_ state: CalculatorState)
}

final class UserDefaultsStateStore: StateStoring {
    private let defaults: UserDefaults
    private let key = "calculator.state"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> CalculatorState? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(CalculatorState.self, from: data)
    }

    func save(_ state: CalculatorState) {
        guard let data = try? JSONEncoder().encode(state) else { return }
        defaults.set(data, forKey: key)
    }
}

final class InMemoryStateStore: StateStoring {
    private(set) var saved: CalculatorState?

    init(initial: CalculatorState? = nil) {
        saved = initial
    }

    func load() -> CalculatorState? { saved }
    func save(_ state: CalculatorState) { saved = state }
}
