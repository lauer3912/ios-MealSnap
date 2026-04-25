import UIKit

final class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        setupViewControllers()
    }

    private func setupAppearance() {
        tabBar.tintColor = UIColor.primaryColor
        tabBar.backgroundColor = UIColor.cardBackground

        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.cardBackground
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = appearance
        }
    }

    private func setupViewControllers() {
        let dashboardVC = DashboardViewController()
        let dashboardNav = UINavigationController(rootViewController: dashboardVC)
        dashboardNav.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house.fill"), tag: 0)

        let searchVC = FoodSearchViewController()
        let searchNav = UINavigationController(rootViewController: searchVC)
        searchNav.tabBarItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: 1)

        let recipesVC = RecipesViewController()
        let recipesNav = UINavigationController(rootViewController: recipesVC)
        recipesNav.tabBarItem = UITabBarItem(title: "Recipes", image: UIImage(systemName: "book.fill"), tag: 2)

        let settingsVC = SettingsViewController()
        let settingsNav = UINavigationController(rootViewController: settingsVC)
        settingsNav.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gearshape.fill"), tag: 3)

        viewControllers = [dashboardNav, searchNav, recipesNav, settingsNav]
    }
}