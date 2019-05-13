//
//  MainCoordinator.swift
//  BulgarianCulture
//
//  Created by Teodor Evgeniev Yanev on 20.04.19.
//  Copyright © 2019 Stamsoft. All rights reserved.
//

import Foundation
import SideMenu
import KVNProgress
import Localize_Swift

extension MainCoordinator: Coordinator { }
extension RegistrationClient: IRegistrationService, ILoginService { }
extension NetworkClient: IHeritagesService, IQuizService, IScoresService { }

class MainCoordinator {
    typealias LogOut = () -> Void

    var logOut: LogOut!

    private let cells: [Cell]
    private var theme: Theme
    private var items: HeritagesResponse?
    private var user: User
    private var networking: Networking

    var childs = [Coordinator]()

    let mainNavigationController = UINavigationController()
    var containerViewController: MainContainerViewController
    var menuViewController: MenuViewController

    init(_ cells: [Cell],
         theme: Theme,
         user: User,
         networking: Networking) {
        self.cells = cells
        self.theme = theme
        self.user = user
        self.networking = networking
        menuViewController = MenuViewController(self.cells, theme: theme)
        containerViewController = MainContainerViewController(menuViewController)
    }

    func start() -> UIViewController {
        menuViewController.delegate = self
        showQuiz(animated: false)
        mainNavigationController.viewControllers = [containerViewController]
        if #available(iOS 11.0, *) {
            mainNavigationController.navigationBar.prefersLargeTitles = true
        }
        return mainNavigationController
    }

    func showQuiz(animated: Bool) {
        let quizCoordinator = QuizCoordinator(theme: theme,
                                              user: user,
                                              quizService: networking.registered,
                                              navigationController: mainNavigationController)
        quizCoordinator.quizCompleted = {
            self.showScores(animated: false)
            self.remove(coordinator: quizCoordinator)
        }
        add(coordinator: quizCoordinator)
        if let _ = containerViewController.currentViewController {
            containerViewController.title = "Quiz".localized()
            containerViewController.dismissViewController(quizCoordinator.start(), animated: animated)
        } else {
            containerViewController.title = "Intro".localized()
            containerViewController.presentViewController(quizCoordinator.start(), animated: animated)
        }
    }

    func showHeritages(animated: Bool) {
        let saveResults: (HeritagesResponse) -> () = { [weak self] heritagesResponse in
            guard let strongSelf = self else { return }
            strongSelf.items = heritagesResponse
        }

        containerViewController.title = "All Heritages".localized()
        let heritagesCoordinator = HeritagesCoordinator(theme: theme,
                                                        service: networking.registered,
                                                        navigationController: mainNavigationController,
                                                        items: items,
                                                        saveResults: saveResults)
        add(coordinator: heritagesCoordinator)
        containerViewController.dismissViewController(heritagesCoordinator.start(), animated: animated)
    }
    
    func showScores(animated: Bool) {
        containerViewController.title = "Scores".localized()
        let scoresCoordinator = ScoresCoordinator(theme: theme, scoresService: networking.registered)
        add(coordinator: scoresCoordinator)
        containerViewController.dismissViewController(scoresCoordinator.start(), animated: animated)
    }
}

extension MainCoordinator: MenuViewControllerDelegate {
    func menuViewController(_ controller: MenuViewController, didSelectItemAt indexPath: IndexPath) {
        let cell = self.cells[indexPath.row]

        remove(coordinator: childs.last)
        containerViewController.dismissMenu(animated: true)

        switch cell.identifier {
        case .quiz:
            showQuiz(animated: false)
        case .heritage:
            showHeritages(animated: false)
        case .scores:
            showScores(animated: false)
        }
    }

    func menuViewControllerDidPressedLogOut(_ controller: MenuViewController) {
        containerViewController.dismissMenu(animated: true)
        logOut()
    }
}
