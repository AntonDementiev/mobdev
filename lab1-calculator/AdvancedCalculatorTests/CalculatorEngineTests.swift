import XCTest
@testable import AdvancedCalculator

final class CalculatorEngineTests: XCTestCase {

    private let engine = CalculatorEngine()

    private func value(_ expression: String) throws -> Double {
        try engine.evaluate(expression)
    }

    private func assertError(_ expression: String, _ expected: CalculatorError,
                             file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertThrowsError(try engine.evaluate(expression), file: file, line: line) { error in
            XCTAssertEqual(error as? CalculatorError, expected, file: file, line: line)
        }
    }


    func testPrecedence() throws {
        XCTAssertEqual(try value("12+5×3"), 27)
        XCTAssertEqual(try value("(12+5)×3"), 51)
        XCTAssertEqual(try value("20÷4+7"), 12)
        XCTAssertEqual(try value("10−2−3"), 5)
        XCTAssertEqual(try value("8÷2÷2"), 2)
    }

    func testDecimalsAndSigns() throws {
        XCTAssertEqual(try value("15.5×2"), 31)
        XCTAssertEqual(try value("−5+3"), -2)
        XCTAssertEqual(try value("2×(−3)"), -6)
        XCTAssertEqual(try value("0.1+0.2"), 0.3, accuracy: 1e-12)
    }

    func testPercent() throws {
        XCTAssertEqual(try value("50%"), 0.5)
        XCTAssertEqual(try value("200×10%"), 20)
    }



    func testDivisionByZero()        { assertError("5÷0", .divisionByZero); assertError("5÷(2−2)", .divisionByZero) }
    func testParentheses()           { assertError("(1+2", .mismatchedParentheses); assertError("1+2)", .mismatchedParentheses) }
    func testConsecutiveOperators()  { assertError("5+×3", .consecutiveOperators) }
    func testMultipleDecimalPoints() { assertError("1.2.3+1", .multipleDecimalPoints) }
    func testEmptyExpression()       { assertError("", .emptyExpression); assertError("   ", .emptyExpression) }
    func testTrailingOperator()      { assertError("5+", .trailingOperator) }
    func testMissingOperand()        { assertError("×5", .missingOperand); assertError("()", .missingOperand) }


    func testFormatting() {
        XCTAssertEqual(NumberFormatting.string(from: 27), "27")
        XCTAssertEqual(NumberFormatting.string(from: 0.1 + 0.2), "0.3")
        XCTAssertEqual(NumberFormatting.string(from: -5), "−5")
    }
}

final class CalculatorViewModelTests: XCTestCase {

    private func makeViewModel() -> CalculatorViewModel {
        CalculatorViewModel(store: InMemoryStateStore())
    }

    func testEvaluateAddsHistory() {
        let vm = makeViewModel()
        vm.inputDigit(1); vm.inputDigit(2); vm.inputOperator(.plus)
        vm.inputDigit(5); vm.inputOperator(.multiply); vm.inputDigit(3)
        vm.evaluate()
        XCTAssertEqual(vm.state.expression, "27")
        XCTAssertEqual(vm.state.history.first, HistoryItem(expression: "12+5×3", result: "27"))
    }

    func testHistoryLimit() {
        let vm = makeViewModel()
        for _ in 0..<15 { vm.inputDigit(1); vm.evaluate() }
        XCTAssertEqual(vm.state.history.count, 10)
    }

    func testSelectHistoryRestoresExpression() {
        let vm = makeViewModel()
        vm.inputDigit(2); vm.inputOperator(.plus); vm.inputDigit(2); vm.evaluate()
        vm.clear()
        vm.selectHistoryItem(at: 0)
        XCTAssertEqual(vm.state.expression, "2+2")
    }

    func testErrorDoesNotCrashAndIsShown() {
        let vm = makeViewModel()
        vm.inputDigit(5); vm.inputOperator(.divide); vm.inputDigit(0)
        vm.evaluate()
        XCTAssertEqual(vm.state.error, .divisionByZero)
        XCTAssertEqual(vm.state.expression, "5÷0")   
        vm.backspace()
        XCTAssertNil(vm.state.error)
    }

    func testMemory() {
        let vm = makeViewModel()
        vm.inputDigit(5); vm.memoryAdd()
        vm.clear(); vm.inputDigit(2); vm.memorySubtract()
        XCTAssertEqual(vm.state.memory, 3)
        vm.clear(); vm.memoryRecall()
        XCTAssertEqual(vm.state.expression, "3")
        vm.memoryClear()
        XCTAssertEqual(vm.state.memory, 0)
    }

    func testToggleSign() {
        XCTAssertEqual(SignToggler.toggle("12+5"), "12+(−5)")
        XCTAssertEqual(SignToggler.toggle("12+(−5)"), "12+5")
        XCTAssertEqual(SignToggler.toggle("−5"), "5")
        XCTAssertEqual(SignToggler.toggle("7"), "(−7)")
    }

    func testStateIsRestoredFromStore() {
        let store = InMemoryStateStore()
        let vm = CalculatorViewModel(store: store)
        vm.inputDigit(4); vm.memoryAdd()
        let restored = CalculatorViewModel(store: store)
        XCTAssertEqual(restored.state, vm.state)
    }
}
