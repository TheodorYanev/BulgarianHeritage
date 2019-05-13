//
//  UIView+init.swift
//  BulgarianCulture
//
//  Created by Teodor Evgeniev Yanev on 4.05.19.
//  Copyright © 2019 Stamsoft. All rights reserved.
//

import UIKit

extension UIView {
    
    func display(inContainer container: UIView!) -> Void {
        self.translatesAutoresizingMaskIntoConstraints = false;
        self.frame = container.frame;
        container.addSubview(self);
        NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
    }
}

extension UIView  {
    func commonInit<C>(_ type: C.Type, contentView: UIView) where C: NibLoadableView {
        Bundle.main.loadNibNamed(type.nibName, owner: self, options: nil)
        contentView.display(inContainer: self)
    }
}

