
import Combine
import UIKit

// MARK: - BaseViewController

class BaseViewController: UIViewController {}

extension UIViewController {
    func showErrorAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        // Add an OK action
        let okAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        alertController.addAction(okAction)

        // Present the alert
        present(alertController, animated: true, completion: nil)
    }
}
