import UIKit

final class HistoryViewController: UITableViewController {

    var onSelect: ((Int) -> Void)?
    var onClear: (() -> Void)?

    private var items: [HistoryItem]
    private let cellId = "HistoryCell"

    init(items: [HistoryItem]) {
        self.items = items
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) не используется")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "История"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Очистить",
            primaryAction: UIAction { [weak self] _ in
                self?.items.removeAll()
                self?.onClear?()
                self?.tableView.reloadData()
                self?.updateEmptyState()
            }
        )
        updateEmptyState()
    }

    private func updateEmptyState() {
        if items.isEmpty {
            let label = UILabel()
            label.text = "История пуста"
            label.textColor = .secondaryLabel
            label.textAlignment = .center
            tableView.backgroundView = label
        } else {
            tableView.backgroundView = nil
        }
        navigationItem.rightBarButtonItem?.isEnabled = !items.isEmpty
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        let item = items[indexPath.row]

        var content = cell.defaultContentConfiguration()
        content.text = "\(item.expression) = \(item.result)"
        content.textProperties.font = .monospacedDigitSystemFont(ofSize: 20, weight: .regular)
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        onSelect?(indexPath.row)
    }
}
