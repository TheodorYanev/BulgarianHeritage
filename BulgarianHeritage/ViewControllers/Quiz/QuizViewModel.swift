//
//  QuizViewModel.swift
//  BulgarianCulture
//
//  Created by Teodor Evgeniev Yanev on 6.05.19.
//  Copyright © 2019 Stamsoft. All rights reserved.
//

import Foundation
import RxSwiftExt
import RxSwift
import RxCocoa
import Localize_Swift

protocol IQuizService {
    func getQuizQA(with parameters: QuizQAParameters, completion: @escaping NetworkCallback<[QuizQAResponse]>)
    func postQuizScore(with parameters: ScoreParameters, completion: @escaping NetworkCallback<Bool>) 
}

protocol QuizViewModelInputs {
    func viewDidLoad()
    func quizButtonPressed()
}

protocol QuizViewModelOutputs {
    
    var quizRequestStatus: Driver<RequestResult> { get }
    var quizError: Driver<String> { get }
    var quizStart: Driver<QuizQAResponse> { get }
}

protocol QuizViewModelType {
    var inputs: QuizViewModelInputs { get }
    var outputs: QuizViewModelOutputs { get }
}


class QuizViewModel: QuizViewModelType, QuizViewModelInputs, QuizViewModelOutputs {

    private let disposeBag = DisposeBag()
    private let viewDidLoadSubject = PublishSubject<Void>()
    private let quizButtonPressedSubject = PublishSubject<Void>()

    var quizRequestStatus: Driver<RequestResult>
    var quizError: Driver<String>
    var quizStart: Driver<QuizQAResponse>
    
    var inputs: QuizViewModelInputs { return self }
    var outputs: QuizViewModelOutputs { return self }
    
    init(quizService: IQuizService) {
        let quizRequestStatusSubject = BehaviorSubject<RequestResult>(value: .notStarted)
        quizRequestStatus = quizRequestStatusSubject
            .asDriver(onErrorJustReturn: .notStarted)
            .distinctUntilChanged()
        
        let quizErrorSubject = PublishSubject<String>()
        quizError = quizErrorSubject
            .asDriver(onErrorJustReturn: "")
        
        let quizFetchedSubject = BehaviorSubject<QuizQAResponse?>(value: nil)
        let quizFetched = quizFetchedSubject
            .asDriver(onErrorJustReturn: nil)
        
        let quizStartSubject = PublishSubject<QuizQAResponse>()
        quizStart = quizStartSubject
            .asNoErrorDriver()
        
        let viewDidLoad = viewDidLoadSubject
            .withUnretained(self)
            .asNoErrorDriver()
        
        let getAllQuizQA = viewDidLoad
        
        getAllQuizQA
            .drive(onNext: { (weakSelf, _) in
                let parameters = QuizQAParameters()
                quizService.getQuizQA(with: parameters, completion: { (response) in
                    switch response {
                    case .successful(value: let quizQA):
                        let quizesCount = quizQA.count
                        guard let randomQuizIndex = (0..<quizesCount).randomElement() else {
                            return quizFetchedSubject.onNext(nil)
                        }
                        print(randomQuizIndex)
                        quizFetchedSubject.onNext(quizQA[randomQuizIndex])
                    case .failed(error: _):
                        return quizFetchedSubject.onNext(nil)
                    }
                })
            })
            .disposed(by: disposeBag)
        
        let quizButtonPressed = quizButtonPressedSubject
            .withUnretained(self)
            .asNoErrorDriver()
        
        quizButtonPressed
            .withLatestFrom(quizFetched)
            .drive(onNext: { response in
                guard let quizQA = response else {
                    quizErrorSubject.onNext("There are no loaded quiz! Check your network connection and try again later!".localized())
                    return
                }
                quizStartSubject.onNext(quizQA)
            })
            .disposed(by: disposeBag)
    }
    
    func viewDidLoad() {
        viewDidLoadSubject.onNext(())
    }
    
    func quizButtonPressed() {
        quizButtonPressedSubject.onNext(())
    }
}
