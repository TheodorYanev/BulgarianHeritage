//
//  QAScoreViewModel.swift
//  BulgarianCulture
//
//  Created by Teodor Evgeniev Yanev on 7.05.19.
//  Copyright © 2019 Stamsoft. All rights reserved.
//

import Foundation
import Localize_Swift
import RxSwiftExt
import RxSwift
import RxCocoa

struct ScoreResponseSentence {
    var score: Int
    func sentence() -> String {
        switch score {
        case 0...4:
            return "You have failed. Good luck next time!".localized()
        case 5...7:
            return "You have done fine.".localized()
        case 8...9:
            return "Good! Your score is pretty good! Good luck next time.".localized()
        case 10...11:
            return "Very Good! You almost have done excellent!".localized()
        case 12:
            return "EXCELLENT! You are from the best ones!".localized()
        default:
            return ""
        }
    }
}

protocol QAScoreViewModelInputs {
    func finishQuizPressed()
    func viewDidLoad()
}

protocol QAScoreViewModelOutputs {
    var scoreLabelText: Driver<String?> { get }
    var quizScoreRequestStatus: Driver<RequestResult> { get }
    var quizCompleted: Driver<Void> { get }
    var quizError: Driver<String> { get }
}

protocol QAScoreViewModelType {
    var inputs: QAScoreViewModelInputs { get }
    var outputs: QAScoreViewModelOutputs { get }
}

class QAScoreViewModel: QAScoreViewModelType, QAScoreViewModelInputs, QAScoreViewModelOutputs {

    private var score = 0
    private let disposeBag = DisposeBag()

    private let finishQuizPressedSubject = PublishSubject<Void>()
    private let viewDidLoadSubject = PublishSubject<Void>()

    var scoreLabelText: Driver<String?>
    var quizScoreRequestStatus: Driver<RequestResult>
    var quizCompleted: Driver<Void>
    var quizError: Driver<String>

    var inputs: QAScoreViewModelInputs { return self }
    var outputs: QAScoreViewModelOutputs { return self }

    init(username: String, questions: [Question], quizId: UUID, quizService: IQuizService) {

        let scoreLabelSubject = BehaviorSubject<String?>(value: nil)
        scoreLabelText = scoreLabelSubject
            .asDriver(onErrorJustReturn: nil)

        let quizScoreRequestStatusSubject = BehaviorSubject<RequestResult>(value: .notStarted)
        quizScoreRequestStatus = quizScoreRequestStatusSubject
            .asDriver(onErrorJustReturn: .notStarted)
            .distinctUntilChanged()

        let quizCompletedSubject = PublishSubject<Void>()
        quizCompleted = quizCompletedSubject
            .asNoErrorDriver()
            .delay(2.0)

        let quizErrorSubject = PublishSubject<String>()
        quizError = quizErrorSubject
            .asDriver(onErrorJustReturn: "")
            .delay(2.0)

        let viewDidLoad = viewDidLoadSubject
            .withUnretained(self)
            .asNoErrorDriver()

        let finishQuizPressed = finishQuizPressedSubject
            .withUnretained(self)
            .asNoErrorDriver()

        viewDidLoad
            .drive(onNext: { (weakSelf, _) in
                for question in questions {
                    print(question.correct_answer_id)
                    print(question.answer_id ?? "")
                    if question.correct_answer_id == question.answer_id {
                        weakSelf.score += 1
                    }
                }
                scoreLabelSubject.onNext(
                    "You got ".localized() +
                        String(weakSelf.score) +
                        " points from 12. ".localized() +
                        ScoreResponseSentence(score: weakSelf.score).sentence()
                )
            })
            .disposed(by: disposeBag)

        finishQuizPressed
            .drive(onNext: { (weakSelf, _) in
                quizScoreRequestStatusSubject.onNext(.inProgress(message: nil))
                let parameters = ScoreParameters(username: username, score: weakSelf.score, quizId: quizId, id: UUID.init())
                quizService.postQuizScore(with: parameters, completion: { (result) in
                    switch result {
                    case .successful:
                        quizScoreRequestStatusSubject.onNext(.success(message: "Save succeeded!".localized()))
                        quizCompletedSubject.onNext(())
                    case .failed(error: let networkError):
                        quizScoreRequestStatusSubject.onNext(.error(message: networkError.error ?? "Save failed!".localized()))
                        quizErrorSubject.onNext(networkError.error ?? "There is problem with saving your score. Check your internet connection and try again!".localized())

                    }
                })
            })
            .disposed(by: disposeBag)

    }

    func finishQuizPressed() {
        finishQuizPressedSubject.onNext(())
    }

    func viewDidLoad() {
        viewDidLoadSubject.onNext(())
    }
}
