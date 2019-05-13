//
//  ScoresCoordinator.swift
//  BulgarianCulture
//
//  Created by Teodor Evgeniev Yanev on 11.05.19.
//  Copyright © 2019 Stamsoft. All rights reserved.
//

import Foundation
import UIKit

class ScoresCoordinator: Coordinator {
    
    private let theme: Theme
    private let scoresService: IScoresService

    var childs = [Coordinator]()
    
    
    init(theme: Theme,
         scoresService: IScoresService) {
        
        self.theme = theme
        self.scoresService = scoresService
    }
    
    func start() -> UIViewController {
        return scoresViewController()
    }
    
    private func scoresViewController() -> ScoresViewController {
        let scoresViewModel = ScoresViewModel(scoresService: scoresService)
        let scoresViewController = ScoresViewController(theme: theme, viewModel: scoresViewModel)
        
        return scoresViewController
    }
}
