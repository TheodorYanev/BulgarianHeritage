//
//  ReusableAndNibLoadableView.swift
//  BulgarianCulture
//
//  Created by Teodor Evgeniev Yanev on 26.04.19.
//  Copyright © 2019 Stamsoft. All rights reserved.
//
import UIKit

protocol NibLoadableView: class {
    static var nibName: String { get }
    static var nib: UINib { get }
}

protocol ReusableView: class {
    static var reuseIdentifier: String { get }
}

extension NibLoadableView {
    static var nibName: String {
        return String(describing: self)
    }
    static var nib: UINib {
        return UINib(nibName: Self.nibName, bundle: nil)
    }
}

extension NibLoadableView where Self: UIView {
    static func instanceFromNib() -> Self {
        return (Self.nib.instantiate(withOwner: nil, options: nil)[0] as? Self)!
    }
}

extension ReusableView {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UITableView {

    func register<C: ReusableView>(cellClass: C.Type) where C: NibLoadableView {
        register(C.nib, forCellReuseIdentifier: cellClass.reuseIdentifier)
    }

    func dequeueReusableCell<T: UITableViewCell> (for indexPath: IndexPath) ->
    T where T: ReusableView {
        guard let cell = dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("The dequeued cell is not an instance of \(T.reuseIdentifier).")
        }
        return cell
    }

}

typealias ReusableTableViewCell = (UITableViewCell & ReusableView & NibLoadableView)
