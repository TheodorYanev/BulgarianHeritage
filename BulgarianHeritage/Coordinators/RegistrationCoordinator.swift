//
//  RegistrationCoordinator.swift
//  BulgarianCulture
//
//  Created by Teodor Evgeniev Yanev on 1.05.19.
//  Copyright © 2019 Stamsoft. All rights reserved.
//

import Foundation
import UIKit

extension RegistrationCoordinator: Coordinator { }

class RegistrationCoordinator {
    typealias LoginCompleted = (String, String) -> Void
    
    var loginCompleted: LoginCompleted!

    var theme: Theme
    var accountService: CachedUserManager
    var networking: Networking

    var childs = [Coordinator]()

    let navigationController = UINavigationController()

    init(theme: Theme,
         accountService: CachedUserManager,
         networking: Networking) {
        self.theme = theme
        self.accountService = accountService
        self.networking = networking
    }

    func start() -> UIViewController {
        navigationController.viewControllers = [loginViewController()]
        if #available(iOS 11.0, *) {
            navigationController.navigationBar.prefersLargeTitles = true
        }
        return navigationController
    }
    
    func loginViewController() -> LoginViewController {
        let loginViewModel = LoginViewModel(networking.registration)
        let loginViewController = LoginViewController(viewModel: loginViewModel,
                                                      theme: theme,
                                                      createAccount: createAccount) { [unowned self] (username, password) in
            self.loginCompleted(username, password)
        }
        return loginViewController
    }

    func registrationViewController() -> RegistrationViewController {
        let registrationViewModel = RegistrationViewModel(networking.registration)
        let registrationViewController = RegistrationViewController(viewModel: registrationViewModel, theme: theme) { [unowned self] (username, password) in
            self.navigationController.popViewController(animated: true)
        }
        return registrationViewController
    }
    
    func createAccount() {
        self.navigationController.pushViewController(registrationViewController(), animated: true)
    }
}
