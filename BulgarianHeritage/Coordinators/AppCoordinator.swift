//
//  AppCoordinator.swift
//  BulgarianCulture
//
//  Created by Teodor Evgeniev Yanev on 1.05.19.
//  Copyright © 2019 Stamsoft. All rights reserved.
//

import Foundation
import Localize_Swift
import UIKit

extension AppCoordinator: Coordinator { }

class AppCoordinator {

    var theme: Theme
    var accountService: CachedUserManager
    var networking: Networking

    var childs = [Coordinator]()

    let appContainerViewController = AppContainerViewController()

    init(theme: Theme,
         accountService: CachedUserManager,
         networking: Networking) {
        self.theme = theme
        self.accountService = accountService
        self.networking = networking
    }

    func start() -> UIViewController {
        if let user = accountService.user {
            showMainContainer(user: user, animated: false)
        } else {
           showRegistration(animated: false)
        }
        return appContainerViewController
    }

    func showRegistration(animated: Bool) {
        let registrationCoordinator = RegistrationCoordinator(theme: theme, accountService: accountService, networking: networking)
        registrationCoordinator.loginCompleted = { [unowned self] (username, password) in
            let user = User(username: username, password: password)
            self.accountService.saveUser(user)
            self.showMainContainer(user: user, animated: true)
            self.remove(coordinator: registrationCoordinator)
        }
        add(coordinator: registrationCoordinator)
        if let _ = appContainerViewController.currentViewController {
            appContainerViewController.dismissViewController(registrationCoordinator.start(), animated: animated)
        } else {
            appContainerViewController.presentViewController(registrationCoordinator.start(), animated: animated)
        }
    }

    func showMainContainer(user: User, animated: Bool) {
        let cells = [
            Cell(title: "All Heritages".localized(), identifier: .heritage),
            Cell(title: "Quiz".localized(), identifier: .quiz),
            Cell(title: "Scores".localized(), identifier: .scores),
        ]

        let mainCoordinator = MainCoordinator(cells, theme: theme, user: user, networking: networking)
        mainCoordinator.logOut = { [unowned self] in
            self.accountService.deleteUser()
            self.remove(coordinator: mainCoordinator)
            self.showRegistration(animated: true)
        }
        add(coordinator: mainCoordinator)
        appContainerViewController.presentViewController(mainCoordinator.start(), animated: animated)
    }

}
