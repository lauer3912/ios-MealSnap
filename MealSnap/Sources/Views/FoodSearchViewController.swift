import UIKit
import SnapKit

final class FoodSearchViewController: UIViewController {

    private var searchResults: [FoodItem] = []

    private lazy var searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.placeholder = "Search foods..."
        bar.searchBarStyle = .minimal
        bar.delegate = self
        return bar
    }()

    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.register(FoodSearchCell.self, forCellReuseIdentifier: "FoodSearchCell")
        tv.backgroundColor = .clear
        tv.delegate = self
        tv.dataSource = self
        tv.separatorStyle = .none
        return tv
    }()

    private lazy var recentSearchesLabel: UILabel = {
        let label = UILabel()
        label.text = "Recent Searches"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = UIColor.textPrimary
        return label
    }()

    private lazy var popularFoodsLabel: UILabel = {
        let label = UILabel()
        label.text = "Popular Foods"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = UIColor.textPrimary
        return label
    }()

    private lazy var popularFoodsStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 8
        return sv
    }()

    private let sampleFoods: [(name: String, cal: Int)] = [
        ("Grilled Chicken Breast", 165), ("Brown Rice", 215), ("Salmon Fillet", 208),
        ("Avocado", 234), ("Greek Yogurt", 100), ("Almonds (1oz)", 164),
        ("Banana", 105), ("Apple", 95), ("Egg", 78), ("Oatmeal", 158)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        title = "Search Foods"
        view.backgroundColor = UIColor.backgroundColor

        view.addSubview(searchBar)
        view.addSubview(tableView)
        view.addSubview(recentSearchesLabel)
        view.addSubview(popularFoodsLabel)
        view.addSubview(popularFoodsStack)

        searchBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
        }

        recentSearchesLabel.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(20)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(recentSearchesLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(popularFoodsLabel.snp.top).offset(-16)
        }

        popularFoodsLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.bottom.equalTo(popularFoodsStack.snp.top).offset(-8)
        }

        popularFoodsStack.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
        }

        setupPopularFoods()
    }

    private func setupPopularFoods() {
        for food in sampleFoods.prefix(5) {
            let row = createFoodRow(name: food.name, calories: food.cal)
            popularFoodsStack.addArrangedSubview(row)
        }
    }

    private func createFoodRow(name: String, calories: Int) -> UIView {
        let row = UIView()
        row.backgroundColor = UIColor.cardBackground
        row.layer.cornerRadius = 8

        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.font = .systemFont(ofSize: 14)
        nameLabel.textColor = UIColor.textPrimary

        let calLabel = UILabel()
        calLabel.text = "\(calories) cal"
        calLabel.font = .systemFont(ofSize: 12)
        calLabel.textColor = UIColor.textSecondary

        let addButton = UIButton(type: .system)
        addButton.setImage(UIImage(systemName: "plus.circle"), for: .normal)
        addButton.tintColor = UIColor.primaryColor

        row.addSubview(nameLabel)
        row.addSubview(calLabel)
        row.addSubview(addButton)

        row.snp.makeConstraints { make in
            make.height.equalTo(44)
        }

        nameLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
        }

        calLabel.snp.makeConstraints { make in
            make.trailing.equalTo(addButton.snp.leading).offset(-8)
            make.centerY.equalToSuperview()
        }

        addButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }

        return row
    }
}

extension FoodSearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            searchResults = []
            tableView.isHidden = true
        } else {
            searchResults = sampleFoods
                .filter { $0.name.lowercased().contains(searchText.lowercased()) }
                .map { FoodItem(id: UUID(), name: $0.name, calories: $0.cal, protein: 0, carbs: 0, fat: 0, fiber: 0, sugar: 0, sodium: 0, servingSize: "1 serving", servingGrams: 100, barcode: nil, photoData: nil, mealType: .snack, date: Date()) }
            tableView.isHidden = false
            tableView.reloadData()
        }
    }
}

extension FoodSearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FoodSearchCell", for: indexPath) as! FoodSearchCell
        cell.configure(with: searchResults[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let food = searchResults[indexPath.row]
        DataService.shared.addFood(food)
        searchBar.text = ""
        searchResults = []
        tableView.isHidden = true
    }
}

final class FoodSearchCell: UITableViewCell {
    private let nameLabel = UILabel()
    private let calorieLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        backgroundColor = .clear
        selectionStyle = .none

        let container = UIView()
        container.backgroundColor = UIColor.cardBackground
        container.layer.cornerRadius = 8

        contentView.addSubview(container)
        container.addSubview(nameLabel)
        container.addSubview(calorieLabel)

        nameLabel.font = .systemFont(ofSize: 14)
        nameLabel.textColor = UIColor.textPrimary

        calorieLabel.font = .systemFont(ofSize: 12)
        calorieLabel.textColor = UIColor.textSecondary

        container.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 20, bottom: 4, right: 20))
        }

        nameLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
        }

        calorieLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
        }
    }

    func configure(with food: FoodItem) {
        nameLabel.text = food.name
        calorieLabel.text = "\(food.calories) cal"
    }
}