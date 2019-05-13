//
//  Rx+RequestResult.swift
//  BulgarianCulture
//
//  Created by Teodor Evgeniev Yanev on 26.04.19.
//  Copyright © 2019 Stamsoft. All rights reserved.
//

import Foundation

enum RequestResult {
    case notStarted
    case inProgress(message: String?)
    case success(message: String?)
    case error(message: String?)
}

extension RequestResult: Equatable { }

import KVNProgress
import RxSwift
import RxCocoa
extension Reactive where Base: UIViewController {
    var requestResult: Binder<RequestResult> {
        return Binder(base) { _, result in
            switch result {
            case .notStarted:
                KVNProgress.dismiss()
            case .inProgress(let message):
                KVNProgress.show(withStatus: message)
            case .success(let message):
                KVNProgress.showSuccess(withStatus: message)
            case .error(let message):
                KVNProgress.showError(withStatus: message)
            }
        }
    }
}
