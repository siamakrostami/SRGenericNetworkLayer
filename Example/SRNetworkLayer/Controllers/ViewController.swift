//
//  ViewController.swift
//  SRNetworkLayer
//
//  Created by Siamak Rostami on 7/25/24.
//

import UIKit

// MARK: - ViewController

class ViewController: UIViewController {
    // MARK: Internal

    override func viewDidLoad() {
        super.viewDidLoad()
        bindLoginResponse()
        asyncLogin()
        // Do any additional setup after loading the view.
    }

    // MARK: Private

    private let viewModel: LoginViewModel = .init()
}

extension ViewController {
    func login() {
        viewModel.login(email: "test@test.com", password: "test")
    }

    func asyncLogin() {
        viewModel.asyncLogin(email: "test@test.com", password: "test")
    }

    func bindLoginResponse() {
        viewModel.$userModel
            .sink { [weak self] _ in
                // Do Something
            }.store(in: &viewModel.loginCancellableSet)
    }
}
