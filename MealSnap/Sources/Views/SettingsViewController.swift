import UIKit
import SnapKit

final class SettingsViewController: UIViewController {

    private let goals = DataService.shared.nutritionGoals

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.backgroundColor = UIColor.backgroundColor
        tv.delegate = self
        tv.dataSource = self
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "SettingsCell")
        tv.register(GoalCell.self, forCellReuseIdentifier: "GoalCell")
        return tv
    }()

    private enum Section: Int, CaseIterable {
        case goals
        case preferences
        case subscription
        case about
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        title = "Settings"
        view.backgroundColor = UIColor.backgroundColor

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .goals: return 4
        case .preferences: return 3
        case .subscription: return 2
        case .about: return 3
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Section(rawValue: section)! {
        case .goals: return "Daily Goals"
        case .preferences: return "Preferences"
        case .subscription: return "Subscription"
        case .about: return "About"
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = Section(rawValue: indexPath.section)!

        switch section {
        case .goals:
            let cell = tableView.dequeueReusableCell(withIdentifier: "GoalCell", for: indexPath) as! GoalCell
            switch indexPath.row {
            case 0:
                cell.configure(title: "Calories", value: "\(goals.dailyCalories)", unit: "cal")
            case 1:
                cell.configure(title: "Protein", value: "\(Int(goals.dailyProtein))", unit: "g")
            case 2:
                cell.configure(title: "Carbs", value: "\(Int(goals.dailyCarbs))", unit: "g")
            case 3:
                cell.configure(title: "Fat", value: "\(Int(goals.dailyFat))", unit: "g")
            default: break
            }
            return cell

        case .preferences:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)
            var config = cell.defaultContentConfiguration()
            switch indexPath.row {
            case 0:
                config.text = "Dark Mode"
                config.secondaryText = ThemeService.shared.isDarkMode ? "On" : "Off"
            case 1:
                config.text = "Meal Reminders"
                config.secondaryText = goals.mealReminders ? "On" : "Off"
            case 2:
                config.text = "Water Intake Goal"
                config.secondaryText = "\(goals.waterIntake) glasses"
            default: break
            }
            cell.contentConfiguration = config
            cell.accessoryType = .disclosureIndicator
            return cell

        case .subscription:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)
            var config = cell.defaultContentConfiguration()
            switch indexPath.row {
            case 0:
                config.text = "Premium Status"
                config.secondaryText = SubscriptionService.shared.isPremium ? "Active" : "Free Plan"
            case 1:
                config.text = "Manage Subscription"
            default: break
            }
            cell.contentConfiguration = config
            cell.accessoryType = .disclosureIndicator
            return cell

        case .about:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)
            var config = cell.defaultContentConfiguration()
            switch indexPath.row {
            case 0:
                config.text = "Version"
                config.secondaryText = "1.0.0"
            case 1:
                config.text = "Privacy Policy"
            case 2:
                config.text = "Terms of Service"
            default: break
            }
            cell.contentConfiguration = config
            cell.accessoryType = .disclosureIndicator
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

final class GoalCell: UITableViewCell {
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    private let unitLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        selectionStyle = .none

        titleLabel.font = .systemFont(ofSize: 16)
        titleLabel.textColor = UIColor.textPrimary

        valueLabel.font = .systemFont(ofSize: 24, weight: .bold)
        valueLabel.textColor = UIColor.primaryColor

        unitLabel.font = .systemFont(ofSize: 14)
        unitLabel.textColor = UIColor.textSecondary

        contentView.addSubview(titleLabel)
        contentView.addSubview(valueLabel)
        contentView.addSubview(unitLabel)

        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }

        valueLabel.snp.makeConstraints { make in
            make.trailing.equalTo(unitLabel.snp.leading).offset(-4)
            make.centerY.equalToSuperview()
        }

        unitLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
    }

    func configure(title: String, value: String, unit: String) {
        titleLabel.text = title
        valueLabel.text = value
        unitLabel.text = unit
    }
}

final class AddFoodViewController: UIViewController {

    private var selectedMealType: FoodItem.MealType = .snack

    private lazy var mealTypeSegment: UISegmentedControl = {
        let items = FoodItem.MealType.allCases.map { $0.rawValue }
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = 3
        control.addTarget(self, action: #selector(mealTypeChanged), for: .valueChanged)
        return control
    }()

    private lazy var nameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Food name"
        tf.borderStyle = .roundedRect
        tf.backgroundColor = UIColor.cardBackground
        return tf
    }()

    private lazy var caloriesTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Calories"
        tf.borderStyle = .roundedRect
        tf.keyboardType = .numberPad
        tf.backgroundColor = UIColor.cardBackground
        return tf
    }()

    private lazy var proteinTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Protein (g)"
        tf.borderStyle = .roundedRect
        tf.keyboardType = .decimalPad
        tf.backgroundColor = UIColor.cardBackground
        return tf
    }()

    private lazy var carbsTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Carbs (g)"
        tf.borderStyle = .roundedRect
        tf.keyboardType = .decimalPad
        tf.backgroundColor = UIColor.cardBackground
        return tf
    }()

    private lazy var fatTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Fat (g)"
        tf.borderStyle = .roundedRect
        tf.keyboardType = .decimalPad
        tf.backgroundColor = UIColor.cardBackground
        return tf
    }()

    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add Food", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.primaryColor
        button.layer.cornerRadius = 12
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        title = "Add Food"
        view.backgroundColor = UIColor.backgroundColor

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTapped))

        view.addSubview(mealTypeSegment)
        view.addSubview(nameTextField)
        view.addSubview(caloriesTextField)
        view.addSubview(proteinTextField)
        view.addSubview(carbsTextField)
        view.addSubview(fatTextField)
        view.addSubview(saveButton)

        mealTypeSegment.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        nameTextField.snp.makeConstraints { make in
            make.top.equalTo(mealTypeSegment.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }

        caloriesTextField.snp.makeConstraints { make in
            make.top.equalTo(nameTextField.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }

        proteinTextField.snp.makeConstraints { make in
            make.top.equalTo(caloriesTextField.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }

        carbsTextField.snp.makeConstraints { make in
            make.top.equalTo(proteinTextField.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }

        fatTextField.snp.makeConstraints { make in
            make.top.equalTo(carbsTextField.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }

        saveButton.snp.makeConstraints { make in
            make.top.equalTo(fatTextField.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
    }

    @objc private func mealTypeChanged() {
        selectedMealType = FoodItem.MealType.allCases[mealTypeSegment.selectedSegmentIndex]
    }

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }

    @objc private func saveTapped() {
        guard let name = nameTextField.text, !name.isEmpty,
              let caloriesText = caloriesTextField.text,
              let calories = Int(caloriesText) else {
            return
        }

        let protein = Double(proteinTextField.text ?? "0") ?? 0
        let carbs = Double(carbsTextField.text ?? "0") ?? 0
        let fat = Double(fatTextField.text ?? "0") ?? 0

        let food = FoodItem(
            id: UUID(),
            name: name,
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat,
            fiber: 0,
            sugar: 0,
            sodium: 0,
            servingSize: "1 serving",
            servingGrams: 100,
            barcode: nil,
            photoData: nil,
            mealType: selectedMealType,
            date: Date()
        )

        DataService.shared.addFood(food)
        dismiss(animated: true)
    }
}