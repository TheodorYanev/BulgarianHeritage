//
//  Rx+SkyFloatingLabelTextField.swift
//  BulgarianCulture
//
//  Created by Teodor Evgeniev Yanev on 27.04.19.
//  Copyright © 2019 Stamsoft. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import SkyFloatingLabelTextField

extension Reactive where Base: SkyFloatingLabelTextField {
    var errorMessage: Binder<String?> {
        return Binder(base) { textField, errorMessage in
            textField.errorMessage = errorMessage
        }
    }
}
