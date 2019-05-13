//
//  Rx+UIColor.swift
//  BulgarianCulture
//
//  Created by Teodor Evgeniev Yanev on 26.04.19.
//  Copyright © 2019 Stamsoft. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UIView {
    var backgroundColor: Binder<UIColor> {
        return Binder(base) { view, color in
            view.backgroundColor = color
        }
    }
}

extension Reactive where Base: UILabel {
    var textColor: Binder<UIColor?> {
        return Binder(base) { textField, color in
            guard let color = color else { return }
            textField.textColor = color
        }
    }
}
