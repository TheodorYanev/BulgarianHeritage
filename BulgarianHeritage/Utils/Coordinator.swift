//
//  Coordinator.swift
//  BulgarianCulture
//
//  Created by Teodor Evgeniev Yanev on 20.04.19.
//  Copyright © 2019 Stamsoft. All rights reserved.
//

import Foundation
import UIKit

protocol Coordinator: class {
    var childs: [Coordinator] { get set }
    func start() -> UIViewController
}

extension Coordinator {
    
    /// Add a child coordinator to the parent
    func add(coordinator: Coordinator) {
        childs.append(coordinator)
    }
    
    /// Remove a child coordinator from the parent
    func remove(coordinator: Coordinator?) {
        guard let coordinator = coordinator else { return }
        childs = childs.filter { $0 !== coordinator }
    }
    
}
