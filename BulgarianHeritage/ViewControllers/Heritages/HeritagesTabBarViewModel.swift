//
//  HeritagesTabBarViewModel.swift
//  BulgarianCulture
//
//  Created by Teodor Evgeniev Yanev on 5.05.19.
//  Copyright © 2019 Stamsoft. All rights reserved.
//

import Foundation
import RxSwift
import RxSwiftExt
import RxCocoa
import Localize_Swift

protocol IHeritagesService {
    func getAllHeritages(completion: @escaping NetworkCallback<[HeritagesResponse]>)
}

protocol HeritagesTabBarViewModelInputs {
    func viewDidLoad()
}

protocol HeritagesTabBarViewModelOutputs {
    var fetchRequestStatus: Driver<RequestResult> { get }
    var fetchError: Driver<String> { get }
    var fetchCompleted: Driver<HeritagesResponse?> { get }
}
protocol HeritagesTabBarViewModelType {
    var inputs: HeritagesTabBarViewModelInputs { get }
    var outputs: HeritagesTabBarViewModelOutputs { get }
}

class HeritagesTabBarViewModel: HeritagesTabBarViewModelInputs, HeritagesTabBarViewModelOutputs, HeritagesTabBarViewModelType {

    private let disposeBag = DisposeBag()
    private let viewDidLoadSubject = PublishSubject<Void>()

    var items: HeritagesResponse?

    var fetchRequestStatus: Driver<RequestResult>
    var fetchError: Driver<String>
    var fetchCompleted: Driver<HeritagesResponse?>

    var inputs: HeritagesTabBarViewModelInputs { return self }
    var outputs: HeritagesTabBarViewModelOutputs { return self }

    init(heritageService: IHeritagesService, items: HeritagesResponse? = nil) {
        
        self.items = items

        let fetchRequestStatusSubject = BehaviorSubject<RequestResult>(value: .notStarted)
        fetchRequestStatus = fetchRequestStatusSubject
            .asDriver(onErrorJustReturn: .notStarted)
            .distinctUntilChanged()

        let fetchErrorSubject = PublishSubject<String>()
        fetchError = fetchErrorSubject
            .asDriver(onErrorJustReturn: "")
            .delay(2.0)

        let fetchCompletedSubject = PublishSubject<HeritagesResponse?>()
        fetchCompleted = fetchCompletedSubject
            .asDriver(onErrorJustReturn: nil)

        let viewDidLoad = viewDidLoadSubject
            .asDriver(onErrorJustReturn: ())
        
        let loadHeritages = viewDidLoad
            .withUnretained(self)
            .delay(0.1)
        
        loadHeritages
            .drive(onNext: { (weakSelf, _) in
                if let items = items {
                    fetchCompletedSubject.onNext(items)
                }
            })
            .disposed(by: disposeBag)

        let getAllHeritages = viewDidLoad

        getAllHeritages
            .drive(onNext: { ( _) in
                guard items == nil else { return }
                fetchRequestStatusSubject.onNext(.inProgress(message: nil))
                heritageService.getAllHeritages { [weak self] (response) in
                    guard let strongSelf = self else { return }
                    switch response {
                    case .successful(value: let result):
                        if let heritages = result.first {
                            strongSelf.items = heritages
                            fetchCompletedSubject.onNext(heritages)
                            fetchRequestStatusSubject.onNext(.notStarted)
                        } else {
                            fetchErrorSubject.onNext("There are not found any haritages information".localized())
                            fetchRequestStatusSubject.onNext(.error(message: "Request failed!".localized()))
                        }
                    case .failed(error: let networkError):
                        fetchErrorSubject.onNext(networkError.error ?? "There are not found any haritages information".localized())
                        fetchRequestStatusSubject.onNext(.error(message: networkError.error ?? "Request failed!".localized()))
                    }
                }
            })
            .disposed(by: disposeBag)
    }
}

extension HeritagesTabBarViewModel {
    func viewDidLoad() {
        viewDidLoadSubject.onNext(())
    }
}
