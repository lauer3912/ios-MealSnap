import UIKit
import SnapKit
import Combine

final class DashboardViewController: UIViewController {

    private let viewModel = DashboardViewModel()
    private var cancellables = Set<AnyCancellable>()

    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        return sv
    }()

    private lazy var contentView = UIView()

    private lazy var greetingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = UIColor.textPrimary
        return label
    }()

    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = UIColor.textSecondary
        return label
    }()

    private lazy var calorieCard: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.cardBackground
        view.layer.cornerRadius = 16
        return view
    }()

    private lazy var calorieProgressRing: CircularProgressView = {
        let view = CircularProgressView()
        return view
    }()

    private lazy var calorieLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = UIColor.textPrimary
        label.textAlignment = .center
        return label
    }()

    private lazy var calorieStatusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = UIColor.textSecondary
        label.textAlignment = .center
        return label
    }()

    private lazy var macroStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.spacing = 12
        return sv
    }()

    private lazy var proteinCard = createMacroCard(title: "Protein", color: UIColor.proteinColor)
    private lazy var carbsCard = createMacroCard(title: "Carbs", color: UIColor.carbsColor)
    private lazy var fatCard = createMacroCard(title: "Fat", color: UIColor.fatColor)

    private lazy var mealsTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Today's Meals"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = UIColor.textPrimary
        return label
    }()

    private lazy var addMealButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        button.tintColor = UIColor.primaryColor
        button.addTarget(self, action: #selector(addMealTapped), for: .touchUpInside)
        return button
    }()

    private lazy var mealsStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 8
        return sv
    }()

    private lazy var weeklyChartView: WeeklyCaloriesChartView = {
        let view = WeeklyCaloriesChartView()
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.updateData()
        updateUI()
    }

    private func setupUI() {
        view.backgroundColor = UIColor.backgroundColor
        navigationController?.navigationBar.prefersLargeTitles = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(greetingLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(calorieCard)
        calorieCard.addSubview(calorieProgressRing)
        calorieCard.addSubview(calorieLabel)
        calorieCard.addSubview(calorieStatusLabel)
        contentView.addSubview(macroStackView)
        macroStackView.addArrangedSubview(proteinCard)
        macroStackView.addArrangedSubview(carbsCard)
        macroStackView.addArrangedSubview(fatCard)
        contentView.addSubview(mealsTitleLabel)
        contentView.addSubview(addMealButton)
        contentView.addSubview(mealsStackView)
        contentView.addSubview(weeklyChartView)

        setupConstraints()
    }

    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }

        greetingLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView.safeAreaLayoutGuide).offset(20)
            make.leading.equalToSuperview().offset(20)
        }

        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(greetingLabel.snp.bottom).offset(4)
            make.leading.equalToSuperview().offset(20)
        }

        calorieCard.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(200)
        }

        calorieProgressRing.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(120)
        }

        calorieLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        calorieStatusLabel.snp.makeConstraints { make in
            make.top.equalTo(calorieLabel.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
        }

        macroStackView.snp.makeConstraints { make in
            make.top.equalTo(calorieCard.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(80)
        }

        mealsTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(macroStackView.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(20)
        }

        addMealButton.snp.makeConstraints { make in
            make.centerY.equalTo(mealsTitleLabel)
            make.trailing.equalToSuperview().offset(-20)
            make.width.height.equalTo(32)
        }

        mealsStackView.snp.makeConstraints { make in
            make.top.equalTo(mealsTitleLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        weeklyChartView.snp.makeConstraints { make in
            make.top.equalTo(mealsStackView.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(150)
            make.bottom.equalToSuperview().offset(-20)
        }
    }

    private func updateUI() {
        greetingLabel.text = viewModel.greeting

        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        dateLabel.text = formatter.string(from: Date())

        calorieLabel.text = "\(viewModel.todayNutrition.totalCalories)"
        calorieStatusLabel.text = viewModel.calorieStatusText

        calorieProgressRing.progress = viewModel.calorieProgress
        calorieProgressRing.progressColor = UIColor.primaryColor

        updateMacroCards()

        mealsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for mealType in FoodItem.MealType.allCases {
            let meals = viewModel.getMealsByType(mealType)
            if !meals.isEmpty {
                let section = createMealSection(type: mealType, meals: meals)
                mealsStackView.addArrangedSubview(section)
            }
        }

        if viewModel.todayNutrition.meals.isEmpty {
            let emptyLabel = UILabel()
            emptyLabel.text = "No meals logged yet today"
            emptyLabel.font = .systemFont(ofSize: 14)
            emptyLabel.textColor = UIColor.textSecondary
            emptyLabel.textAlignment = .center
            mealsStackView.addArrangedSubview(emptyLabel)
        }

        weeklyChartView.updateData(viewModel.weeklyCalories)
    }

    private func updateMacroCards() {
        updateMacroCard(proteinCard, value: Int(viewModel.todayNutrition.totalProtein), goal: Int(DataService.shared.nutritionGoals.dailyProtein), color: UIColor.proteinColor)
        updateMacroCard(carbsCard, value: Int(viewModel.todayNutrition.totalCarbs), goal: Int(DataService.shared.nutritionGoals.dailyCarbs), color: UIColor.carbsColor)
        updateMacroCard(fatCard, value: Int(viewModel.todayNutrition.totalFat), goal: Int(DataService.shared.nutritionGoals.dailyFat), color: UIColor.fatColor)
    }

    private func updateMacroCard(_ card: UIView, value: Int, goal: Int, color: UIColor) {
        card.subviews.compactMap { $0 as? UILabel }.forEach { label in
            if label.tag == 1 {
                label.text = "\(value)g"
            } else if label.tag == 2 {
                label.text = "/ \(goal)g"
            }
        }

        if let progressView = card.subviews.compactMap({ $0 as? UIView }).first(where: { $0.tag == 10 }) {
            let progress = CGFloat(value) / CGFloat(max(goal, 1))
            progressView.snp.remakeConstraints { make in
                make.leading.bottom.equalToSuperview()
                make.height.equalTo(4)
                make.width.equalToSuperview().multipliedBy(min(progress, 1.0))
            }
            progressView.backgroundColor = color
        }
    }

    private func createMacroCard(title: String, color: UIColor) -> UIView {
        let card = UIView()
        card.backgroundColor = UIColor.cardBackground
        card.layer.cornerRadius = 12

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 12)
        titleLabel.textColor = UIColor.textSecondary
        titleLabel.tag = 0

        let valueLabel = UILabel()
        valueLabel.text = "0g"
        valueLabel.font = .systemFont(ofSize: 18, weight: .bold)
        valueLabel.textColor = UIColor.textPrimary
        valueLabel.tag = 1

        let goalLabel = UILabel()
        goalLabel.text = "/ 0g"
        goalLabel.font = .systemFont(ofSize: 12)
        goalLabel.textColor = UIColor.textSecondary
        goalLabel.tag = 2

        let progressBar = UIView()
        progressBar.backgroundColor = color.withAlphaComponent(0.3)
        progressBar.layer.cornerRadius = 2
        progressBar.tag = 10

        card.addSubview(titleLabel)
        card.addSubview(valueLabel)
        card.addSubview(goalLabel)
        card.addSubview(progressBar)

        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(12)
        }

        valueLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.equalToSuperview().offset(12)
        }

        goalLabel.snp.makeConstraints { make in
            make.leading.equalTo(valueLabel.snp.trailing).offset(4)
            make.bottom.equalTo(valueLabel)
        }

        progressBar.snp.makeConstraints { make in
            make.leading.bottom.equalToSuperview()
            make.height.equalTo(4)
            make.width.equalTo(0)
        }

        return card
    }

    private func createMealSection(type: FoodItem.MealType, meals: [FoodItem]) -> UIView {
        let container = UIView()

        let headerLabel = UILabel()
        headerLabel.text = type.rawValue
        headerLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        headerLabel.textColor = UIColor.textSecondary

        let caloriesLabel = UILabel()
        let totalCal = meals.reduce(0) { $0 + $1.calories }
        caloriesLabel.text = "\(totalCal) cal"
        caloriesLabel.font = .systemFont(ofSize: 14)
        caloriesLabel.textColor = UIColor.primaryColor

        container.addSubview(headerLabel)
        container.addSubview(caloriesLabel)

        headerLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
        }

        caloriesLabel.snp.makeConstraints { make in
            make.centerY.equalTo(headerLabel)
            make.trailing.equalToSuperview()
        }

        for meal in meals {
            let mealRow = createMealRow(meal)
            container.addSubview(mealRow)
        }

        return container
    }

    private func createMealRow(_ meal: FoodItem) -> UIView {
        let row = UIView()

        let nameLabel = UILabel()
        nameLabel.text = meal.name
        nameLabel.font = .systemFont(ofSize: 14)
        nameLabel.textColor = UIColor.textPrimary

        let calorieLabel = UILabel()
        calorieLabel.text = "\(meal.calories) cal"
        calorieLabel.font = .systemFont(ofSize: 12)
        calorieLabel.textColor = UIColor.textSecondary

        row.addSubview(nameLabel)
        row.addSubview(calorieLabel)

        nameLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
        }

        calorieLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(2)
            make.leading.bottom.equalToSuperview()
        }

        return row
    }

    @objc private func addMealTapped() {
        let addVC = AddFoodViewController()
        let nav = UINavigationController(rootViewController: addVC)
        present(nav, animated: true)
    }
}

final class CircularProgressView: UIView {
    var progress: Double = 0 {
        didSet { setNeedsDisplay() }
    }

    var progressColor: UIColor = UIColor.primaryColor
    var trackColor: UIColor = UIColor.systemGray5

    override func draw(_ rect: CGRect) {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2 - 10
        let lineWidth: CGFloat = 12

        let trackPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        trackPath.lineWidth = lineWidth
        trackColor.setStroke()
        trackPath.stroke()

        let startAngle: CGFloat = -.pi / 2
        let endAngle = startAngle + CGFloat(progress) * .pi * 2

        let progressPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        progressPath.lineWidth = lineWidth
        progressPath.lineCapStyle = .round
        progressColor.setStroke()
        progressPath.stroke()
    }
}

final class WeeklyCaloriesChartView: UIView {
    private var data: [Int] = []

    func updateData(_ newData: [Int]) {
        data = newData
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        guard !data.isEmpty else { return }

        let maxValue = max(data.max() ?? 2000, 1)
        let barWidth: CGFloat = rect.width / CGFloat(data.count + 1)
        var x: CGFloat = barWidth / 2

        let days = ["M", "T", "W", "T", "F", "S", "S"]

        for (index, value) in data.enumerated() {
            let barHeight = CGFloat(value) / CGFloat(maxValue) * (rect.height - 30)

            let barRect = CGRect(x: x, y: rect.height - barHeight - 20, width: barWidth * 0.6, height: barHeight)
            let path = UIBezierPath(roundedRect: barRect, cornerRadius: 4)
            UIColor.primaryColor.setFill()
            path.fill()

            let dayLabel = "\(days[index])"
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 10),
                .foregroundColor: UIColor.textSecondary
            ]
            let size = dayLabel.size(withAttributes: attrs)
            dayLabel.draw(at: CGPoint(x: x + (barWidth * 0.6 - size.width) / 2, y: rect.height - 15), withAttributes: attrs)

            x += barWidth
        }
    }
}