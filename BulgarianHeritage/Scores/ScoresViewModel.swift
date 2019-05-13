//
//  ScoresViewModel.swift
//  BulgarianCulture
//
//  Created by Teodor Evgeniev Yanev on 11.05.19.
//  Copyright © 2019 Stamsoft. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxSwiftExt
import RxDataSources
import Localize_Swift


protocol IScoresService {
    func getAllScores(completion: @escaping NetworkCallback<[ScoreResponse]>)
}

struct SectionOfScores {
    var items: [ScoreResponse]
}

extension SectionOfScores: SectionModelType {
    init(original: SectionOfScores, items: [ScoreResponse]) {
        self = original
        self.items = items
    }
}

protocol ScoresViewModelInputs {
    func viewDidLoad()
}

protocol ScoresViewModelOutputs {
    var scores: Driver<[SectionOfScores]> { get }
    var fetchRequestStatus: Driver<RequestResult> { get }
    var fetchError: Driver<String> { get }
}

protocol ScoresViewModelType {
    var inputs: ScoresViewModelInputs { get }
    var outputs: ScoresViewModelOutputs { get }
}

class ScoresViewModel: ScoresViewModelType, ScoresViewModelInputs, ScoresViewModelOutputs {
    
    private let disposeBag = DisposeBag()
    private let viewDidLoadSubject = PublishSubject<Void>()

    var scores: Driver<[SectionOfScores]>
    var fetchRequestStatus: Driver<RequestResult>
    var fetchError: Driver<String>

    var inputs: ScoresViewModelInputs { return self }
    var outputs: ScoresViewModelOutputs { return self }
    
    init(scoresService: IScoresService) {

        let scoresRelay = BehaviorRelay<[ScoreResponse]>(value: [])
        scores = scoresRelay
            .map({ scores in
                let sorted = scores.sorted{ $0.score > $1.score }
                return [SectionOfScores(items: sorted)]
            })
            .asNoErrorDriver()
        
        let fetchRequestStatusSubject = BehaviorSubject<RequestResult>(value: .notStarted)
        fetchRequestStatus = fetchRequestStatusSubject
            .asDriver(onErrorJustReturn: .notStarted)
            .distinctUntilChanged()
        
        let fetchErrorSubject = PublishSubject<String>()
        fetchError = fetchErrorSubject
            .asDriver(onErrorJustReturn: "")
            .delay(2.0)

        let viewDidLoad = viewDidLoadSubject
            .withUnretained(self)
            .asNoErrorDriver()
        
        let getAllScores = viewDidLoad
        
        getAllScores
            .drive(onNext: { (weakSelf, _) in
                fetchRequestStatusSubject.onNext(.inProgress(message: nil))
                scoresService.getAllScores(completion: { (response) in
                    switch response {
                    case .successful(value: let scores):
                        scoresRelay.accept(scores)
                        fetchRequestStatusSubject.onNext(.notStarted)
                    case .failed(error: let networkError):
                        fetchErrorSubject.onNext(networkError.error ?? "There are not found any scores".localized())
                        fetchRequestStatusSubject.onNext(.error(message: networkError.error ?? "Request failed!".localized()))
                    }
                })
            })
            .disposed(by: disposeBag)
    }

    func viewDidLoad() {
        viewDidLoadSubject.onNext(())
    }
}
