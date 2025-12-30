import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
        setupTabBar()
    }

    private func setupViewControllers() {
        let homeVC = HomeViewController()
        let homeNav = UINavigationController(rootViewController: homeVC)
        homeNav.tabBarItem = UITabBarItem(
            title: "首页",
            image: UIImage(systemName: "house.fill"),
            selectedImage: UIImage(systemName: "house.fill")
        )

        let researchVC = ResearchViewController()
        let researchNav = UINavigationController(rootViewController: researchVC)
        researchNav.tabBarItem = UITabBarItem(
            title: "研究",
            image: UIImage(systemName: "book.fill"),
            selectedImage: UIImage(systemName: "book.fill")
        )

        let libraryVC = LibraryViewController()
        let libraryNav = UINavigationController(rootViewController: libraryVC)
        libraryNav.tabBarItem = UITabBarItem(
            title: "资料库",
            image: UIImage(systemName: "folder.fill"),
            selectedImage: UIImage(systemName: "folder.fill")
        )

        let analysisVC = AnalysisViewController()
        let analysisNav = UINavigationController(rootViewController: analysisVC)
        analysisNav.tabBarItem = UITabBarItem(
            title: "分析",
            image: UIImage(systemName: "chart.bar.fill"),
            selectedImage: UIImage(systemName: "chart.bar.fill")
        )

        let profileVC = ProfileViewController()
        let profileNav = UINavigationController(rootViewController: profileVC)
        profileNav.tabBarItem = UITabBarItem(
            title: "我的",
            image: UIImage(systemName: "person.fill"),
            selectedImage: UIImage(systemName: "person.fill")
        )

        viewControllers = [homeNav, researchNav, libraryNav, analysisNav, profileNav]
    }

    private func setupTabBar() {
        tabBar.tintColor = UIColor(red: 0.07, green: 0.21, blue: 0.36, alpha: 1.0) // #1A365D
        tabBar.unselectedItemTintColor = .systemGray
    }
}