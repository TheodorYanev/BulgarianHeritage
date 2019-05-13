//
//  QuizCoordinator.swift
//  BulgarianCulture
//
//  Created by Teodor Evgeniev Yanev on 20.04.19.
//  Copyright © 2019 Stamsoft. All rights reserved.
//

import Foundation
import UIKit

extension QuizCoordinator: Coordinator { }

class QuizCoordinator {
    typealias NextQuestion = ([Question], Int) -> Void
    typealias ShowQAScore = ([Question]) -> Void
    typealias Interrupted = () -> Void
    typealias Completed = () -> Void

    private let theme: Theme
    private let user: User
    private let quizService: IQuizService
    
    var quizCompleted: Completed!

    private let navigationController: UINavigationController

    var childs = [Coordinator]()


    init(theme: Theme,
         user: User,
         quizService: IQuizService,
         navigationController: UINavigationController) {

        self.theme = theme
        self.user = user
        self.quizService = quizService
        self.navigationController = navigationController
    }

    func start() -> UIViewController {
        return quizViewController()
    }

    func quizViewController() -> QuizViewController {
        let quizViewModel = QuizViewModel(quizService: quizService)
        let quizViewController = QuizViewController(theme: theme, viewModel: quizViewModel) { [weak self] (quizQA) in
            guard let strongSelf = self else { return }
            strongSelf.quizQAViewController(quizId: quizQA.id, questions: quizQA.questions, questionIndex: 0)
        }
        return quizViewController
    }

    func quizQAViewController(quizId: UUID, questions: [Question], questionIndex: Int) {

        let nextQuestion: NextQuestion = { [weak self] (questions, questionIndex) in
            guard let strongSelf = self else { return }
            strongSelf.quizQAViewController(quizId: quizId, questions: questions, questionIndex: questionIndex)
        }

        let showQAScore: ShowQAScore = { [weak self] questions in
            guard let strongSelf = self else { return }
            strongSelf.showQAScore(quizId: quizId, questions: questions)
        }

        let quizQAViewController = QAViewController(theme: theme,
                                                    questions: questions,
                                                    for: questionIndex,
                                                    nextQuestion: nextQuestion,
                                                    showScore: showQAScore)
        navigationController.pushViewController(quizQAViewController, animated: true)
    }

    func showQAScore(quizId: UUID, questions: [Question]) {

        let completed: Completed = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.navigationController.popToRootViewController(animated: false)
            strongSelf.quizCompleted?()
        }

        let interrupted: Interrupted = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.navigationController.popToRootViewController(animated: true)
        }

        let qaScoreViewModel = QAScoreViewModel(username: user.username, questions: questions, quizId: quizId, quizService: quizService)

        let qaScoreViewController = QAScoreViewController(theme: theme,
                                                          viewModel: qaScoreViewModel,
                                                          completed: completed,
                                                          interrupted: interrupted)
        navigationController.pushViewController(qaScoreViewController, animated: true)
    }
}
