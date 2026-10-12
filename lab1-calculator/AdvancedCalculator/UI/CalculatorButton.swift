import UIKit

final class CalculatorButton: UIButton {

    let key: CalculatorKey

    init(key: CalculatorKey) {
        self.key = key
        super.init(frame: .zero)

        setTitle(key.title, for: .normal)
        setTitleColor(key.titleColor, for: .normal)
        setTitleColor(key.titleColor.withAlphaComponent(0.5), for: .highlighted)
        backgroundColor = key.backgroundColor

        let isMemory: Bool
        switch key {
        case .memoryClear, .memoryRecall, .memoryAdd, .memorySubtract: isMemory = true
        default: isMemory = false
        }
        titleLabel?.font = .systemFont(ofSize: isMemory ? 18 : 28, weight: .medium)
        titleLabel?.adjustsFontSizeToFitWidth = true
        accessibilityLabel = key.title
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) не используется — интерфейс создаётся кодом")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = min(bounds.width, bounds.height) / 2  
    }

    override var isHighlighted: Bool {
        didSet { alpha = isHighlighted ? 0.6 : 1 }
    }
}
