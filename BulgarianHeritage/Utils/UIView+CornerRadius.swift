//
//  UIView+CornerRadius.swift
//  BulgarianCulture
//
//  Created by Teodor Evgeniev Yanev on 21.04.19.
//  Copyright © 2019 Stamsoft. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
            self.layer.masksToBounds = true
            self.clipsToBounds = true
        }
    }
}

extension UIView {
    func makeCornersRound() {
        if frame.height < frame.width {
            cornerRadius = frame.height / 2
        } else {
            cornerRadius = frame.width / 2
        }
    }
}
