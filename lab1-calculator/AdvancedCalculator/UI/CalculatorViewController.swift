import UIKit

final class CalculatorViewController: UIViewController {

    private let viewModel: CalculatorViewModel

    private let memoryLabel = UILabel()
    private let infoLabel = UILabel()
    private let expressionLabel = UILabel()
    private let displayStack = UIStackView()
    private let keypadStack = UIStackView()
    private let mainStack = UIStackView()

    private var portraitConstraints: [NSLayoutConstraint] = []
    private var landscapeConstraints: [NSLayoutConstraint] = []
    private var isLandscapeLayout: Bool?

    private let layout: [[CalculatorKey]] = [
        [.memoryClear, .memoryRecall, .memoryAdd, .memorySubtract],
        [.clear, .leftParen, .rightParen, .backspace],
        [.digit(7), .digit(8), .digit(9), .op(.divide)],
        [.digit(4), .digit(5), .digit(6), .op(.multiply)],
        [.digit(1), .digit(2), .digit(3), .op(.minus)],
        [.toggleSign, .digit(0), .point, .op(.plus)],
        [.percent, .equals]
    ]

    private let spacing: CGFloat = 10

    init(viewModel: CalculatorViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) не используется")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Калькулятор"
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "clock.arrow.circlepath"),
            style: .plain,
            target: self,
            action: #selector(showHistory)
        )

        setupDisplay()
        setupKeypad()
        setupLayout()

        viewModel.onStateChange = { [weak self] state in
            self?.render(state)
        }
        render(viewModel.state)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let isLandscape = view.bounds.width > view.bounds.height
        guard isLandscape != isLandscapeLayout else { return }
        isLandscapeLayout = isLandscape
        mainStack.axis = isLandscape ? .horizontal : .vertical
        if isLandscape {
            NSLayoutConstraint.deactivate(portraitConstraints)
            NSLayoutConstraint.activate(landscapeConstraints)
        } else {
            NSLayoutConstraint.deactivate(landscapeConstraints)
            NSLayoutConstraint.activate(portraitConstraints)
        }
    }

    private func setupDisplay() {
        memoryLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        memoryLabel.textColor = .systemOrange
        memoryLabel.textAlignment = .right

        infoLabel.font = .systemFont(ofSize: 20)
        infoLabel.textColor = .secondaryLabel
        infoLabel.textAlignment = .right
        infoLabel.adjustsFontSizeToFitWidth = true
        infoLabel.minimumScaleFactor = 0.5

        expressionLabel.font = .systemFont(ofSize: 56, weight: .light)
        expressionLabel.textAlignment = .right
        expressionLabel.adjustsFontSizeToFitWidth = true
        expressionLabel.minimumScaleFactor = 0.3
        expressionLabel.lineBreakMode = .byTruncatingHead

        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .vertical)

        displayStack.axis = .vertical
        displayStack.spacing = 4
        [spacer, memoryLabel, infoLabel, expressionLabel].forEach(displayStack.addArrangedSubview)
    }

    private func setupKeypad() {
        keypadStack.axis = .vertical
        keypadStack.distribution = .fillEqually
        keypadStack.spacing = spacing

        for row in layout {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = spacing
            rowStack.distribution = row.count == 4 ? .fillEqually : .fill

            for key in row {
                let button = CalculatorButton(key: key)
                button.addAction(UIAction { [weak self] _ in self?.handle(key) }, for: .touchUpInside)
                rowStack.addArrangedSubview(button)
            }
            keypadStack.addArrangedSubview(rowStack)

            if row.count == 2, let percent = rowStack.arrangedSubviews.first {
                percent.widthAnchor.constraint(equalTo: rowStack.widthAnchor,
                                               multiplier: 0.25,
                                               constant: -spacing * 3 / 4).isActive = true
            }
        }
    }

    private func setupLayout() {
        mainStack.axis = .vertical
        mainStack.spacing = 16
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        mainStack.addArrangedSubview(displayStack)
        mainStack.addArrangedSubview(keypadStack)
        view.addSubview(mainStack)

        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: guide.topAnchor, constant: 8),
            mainStack.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -8),
            mainStack.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -16)
        ])

        portraitConstraints = [
            keypadStack.heightAnchor.constraint(equalTo: mainStack.heightAnchor, multiplier: 0.68)
        ]
        landscapeConstraints = [
            keypadStack.widthAnchor.constraint(equalTo: mainStack.widthAnchor, multiplier: 0.55)
        ]
        NSLayoutConstraint.activate(portraitConstraints)
    }

    private func handle(_ key: CalculatorKey) {
        switch key {
        case .digit(let d):   viewModel.inputDigit(d)
        case .op(let op):     viewModel.inputOperator(op)
        case .point:          viewModel.inputDecimalPoint()
        case .leftParen:      viewModel.inputLeftParen()
        case .rightParen:     viewModel.inputRightParen()
        case .clear:          viewModel.clear()
        case .backspace:      viewModel.backspace()
        case .percent:        viewModel.inputPercent()
        case .toggleSign:     viewModel.toggleSign()
        case .equals:         viewModel.evaluate()
        case .memoryClear:    viewModel.memoryClear()
        case .memoryRecall:   viewModel.memoryRecall()
        case .memoryAdd:      viewModel.memoryAdd()
        case .memorySubtract: viewModel.memorySubtract()
        }
    }

    @objc private func showHistory() {
        let history = HistoryViewController(items: viewModel.state.history)
        history.onSelect = { [weak self] index in
            self?.viewModel.selectHistoryItem(at: index)
            self?.navigationController?.popViewController(animated: true)
        }
        history.onClear = { [weak self] in
            self?.viewModel.clearHistory()
        }
        navigationController?.pushViewController(history, animated: true)
    }

    // MARK: - Отрисовка состояния

    private func render(_ state: CalculatorState) {
        expressionLabel.text = state.expression.isEmpty ? "0" : state.expression

        memoryLabel.text = state.hasMemory
            ? "M = \(NumberFormatting.string(from: state.memory))"
            : " "

        if let error = state.error {
            infoLabel.text = "Error " + error.message
            infoLabel.textColor = .systemRed
            expressionLabel.textColor = .systemRed
        } else {
            infoLabel.textColor = .secondaryLabel
            expressionLabel.textColor = .label
            if state.justEvaluated, let last = state.history.first {
                infoLabel.text = "\(last.expression) ="
            } else if let result = state.lastResult {
                infoLabel.text = "Ans = \(result)"
            } else {
                infoLabel.text = " "
            }
        }
    }
}
