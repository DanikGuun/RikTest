
import UIKit

class BaseCoordinator: Coordinator {
    
    let mainViewController: UIViewController
    let viewControllerFactory: ViewControllerFactory
    
    init(viewControllerFactory: ViewControllerFactory) {
        self.viewControllerFactory = viewControllerFactory
        let controller = viewControllerFactory.makeMainStatisticViewController()
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.navigationBar.prefersLargeTitles = true
        self.mainViewController = navigationController
    }
}
