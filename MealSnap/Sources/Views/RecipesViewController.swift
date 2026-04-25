import UIKit
import SnapKit

final class RecipesViewController: UIViewController {

    private var recipes: [Recipe] = []

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(RecipeCell.self, forCellWithReuseIdentifier: "RecipeCell")
        cv.backgroundColor = .clear
        cv.delegate = self
        cv.dataSource = self
        return cv
    }()

    private lazy var segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["All", "Favorites", "Quick Meals"])
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(filterChanged), for: .valueChanged)
        return control
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadSampleRecipes()
    }

    private func setupUI() {
        title = "Recipes"
        view.backgroundColor = UIColor.backgroundColor

        view.addSubview(segmentedControl)
        view.addSubview(collectionView)

        segmentedControl.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom).offset(16)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    private func loadSampleRecipes() {
        recipes = [
            Recipe(id: UUID(), name: "Grilled Chicken Salad", ingredients: ["Chicken breast", "Mixed greens", "Cherry tomatoes", "Olive oil"], instructions: ["Grill chicken", "Mix salad", "Combine"], calories: 350, prepTime: 10, cookTime: 15, servings: 2, imageData: nil, isFavorite: false),
            Recipe(id: UUID(), name: "Overnight Oats", ingredients: ["Oats", "Milk", "Yogurt", "Berries"], instructions: ["Mix ingredients", "Refrigerate overnight"], calories: 280, prepTime: 5, cookTime: 0, servings: 1, imageData: nil, isFavorite: true),
            Recipe(id: UUID(), name: "Salmon with Vegetables", ingredients: ["Salmon fillet", "Broccoli", "Sweet potato"], instructions: ["Preheat oven", "Season salmon", "Roast vegetables", "Bake together"], calories: 420, prepTime: 15, cookTime: 25, servings: 2, imageData: nil, isFavorite: false),
            Recipe(id: UUID(), name: "Protein Smoothie", ingredients: ["Banana", "Protein powder", "Almond milk", "Peanut butter"], instructions: ["Blend all ingredients", "Serve immediately"], calories: 320, prepTime: 5, cookTime: 0, servings: 1, imageData: nil, isFavorite: false),
            Recipe(id: UUID(), name: "Quinoa Buddha Bowl", ingredients: ["Quinoa", "Chickpeas", "Avocado", "Tahini"], instructions: ["Cook quinoa", "Roast chickpeas", "Prepare vegetables", "Assemble bowl"], calories: 480, prepTime: 15, cookTime: 20, servings: 2, imageData: nil, isFavorite: true),
            Recipe(id: UUID(), name: "Egg White Omelette", ingredients: ["Egg whites", "Spinach", "Feta cheese", "Tomatoes"], instructions: ["Whisk egg whites", "Sauté vegetables", "Cook omelette"], calories: 180, prepTime: 5, cookTime: 8, servings: 1, imageData: nil, isFavorite: false)
        ]
        collectionView.reloadData()
    }

    @objc private func filterChanged() {
        var filteredRecipes: [Recipe]!

        switch segmentedControl.selectedSegmentIndex {
        case 0: filteredRecipes = recipes
        case 1: filteredRecipes = recipes.filter { $0.isFavorite }
        case 2: filteredRecipes = recipes.filter { $0.prepTime + $0.cookTime <= 15 }
        default: filteredRecipes = recipes
        }

        collectionView.reloadData()
    }
}

extension RecipesViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recipes.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecipeCell", for: indexPath) as! RecipeCell
        cell.configure(with: recipes[indexPath.row])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 60) / 2
        return CGSize(width: width, height: width * 1.2)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 20)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailVC = RecipeDetailViewController()
        detailVC.recipe = recipes[indexPath.row]
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

final class RecipeCell: UICollectionViewCell {
    private let imageView = UIImageView()
    private let nameLabel = UILabel()
    private let caloriesLabel = UILabel()
    private let timeLabel = UILabel()
    private let favoriteIcon = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        contentView.backgroundColor = UIColor.cardBackground
        contentView.layer.cornerRadius = 12

        imageView.backgroundColor = UIColor.systemGray5
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8

        nameLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        nameLabel.textColor = UIColor.textPrimary
        nameLabel.numberOfLines = 2

        caloriesLabel.font = .systemFont(ofSize: 12)
        caloriesLabel.textColor = UIColor.textSecondary

        timeLabel.font = .systemFont(ofSize: 12)
        timeLabel.textColor = UIColor.textSecondary

        favoriteIcon.image = UIImage(systemName: "heart.fill")
        favoriteIcon.tintColor = UIColor.errorColor

        contentView.addSubview(imageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(caloriesLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(favoriteIcon)

        imageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(8)
            make.height.equalTo(contentView.snp.width).multipliedBy(0.5)
        }

        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(8)
        }

        caloriesLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
        }

        timeLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-8)
            make.bottom.equalToSuperview().offset(-8)
        }

        favoriteIcon.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
            make.width.height.equalTo(20)
        }
    }

    func configure(with recipe: Recipe) {
        nameLabel.text = recipe.name
        caloriesLabel.text = "\(recipe.calories) cal"
        timeLabel.text = "\(recipe.totalTime) min"
        favoriteIcon.isHidden = !recipe.isFavorite
    }
}

final class RecipeDetailViewController: UIViewController {
    var recipe: Recipe?

    private lazy var scrollView = UIScrollView()
    private lazy var contentView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = recipe?.name ?? "Recipe"
        view.backgroundColor = UIColor.backgroundColor
        setupUI()
    }

    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }
    }
}