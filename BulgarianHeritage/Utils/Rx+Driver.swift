//
//  Rx+Driver.swift
//  BulgarianCulture
//
//  Created by Teodor Evgeniev Yanev on 27.04.19.
//  Copyright © 2019 Stamsoft. All rights reserved.
//

import Foundation
import RxSwiftExt
import RxSwift
import RxCocoa

extension ObservableConvertibleType {
    /**
     Converts observable sequence to `Driver` trait.
     - returns: Driver trait.
     */

    func asNoErrorDriver() -> Driver<E> {
        let source = self
            .asObservable()
            .map (Optional.init)
            .asDriver(onErrorJustReturn: nil)
            .map { return $0! }
        
        return source
    }
}


extension Driver {
    func withUnretained<T: AnyObject>(_ obj: T) -> Driver<(T, E)> {
        return self
            .asObservable()
            .withUnretained(obj)
            .asNoErrorDriver()
    }
}
