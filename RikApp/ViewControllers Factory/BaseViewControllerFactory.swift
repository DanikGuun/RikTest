
import UIKit
import RikAPI

public class BaseViewControllerFactory: ViewControllerFactory {
    
    func makeMainStatisticViewController() -> any Coordinatable {
        let api = RikStatisticsApiAdapter(api: RikApi.getInstance())
        let model = BaseMainStatisticModel(api: api)
        let controller = MainStatisticsViewController(model: model)
        return controller
    }
    
    
}
