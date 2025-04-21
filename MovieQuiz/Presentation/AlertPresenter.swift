import UIKit

final class AlertPresenter {
    weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func show(alert model: AlertModel) {
        guard let vc = viewController else { return }
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.completion?()
        })
        vc.present(alert, animated: true)
    }
}
