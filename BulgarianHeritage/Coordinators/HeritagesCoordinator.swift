//
//  HeritagesCoordinator.swift
//  BulgarianCulture
//
//  Created by Teodor Evgeniev Yanev on 22.04.19.
//  Copyright © 2019 Stamsoft. All rights reserved.
//

import Foundation
import UIKit

class HeritagesCoordinator: NSObject, Coordinator {
    typealias SaveResults = (HeritagesResponse) -> ()
    typealias DidSelect = (Heritage, HeritageType) -> ()

    private let saveResults: SaveResults?

    private let theme: Theme
    private let service: IHeritagesService
    private let items: HeritagesResponse?

    let navigationController: UINavigationController

    var childs = [Coordinator]()

    init(theme: Theme,
         service: IHeritagesService,
         navigationController: UINavigationController,
         items: HeritagesResponse? = nil,
         saveResults: SaveResults? = nil) {

        self.theme = theme
        self.service = service
        self.items = items
        self.navigationController = navigationController
        self.saveResults = saveResults

        super.init()
    }

    func start() -> UIViewController {
        return heritageTabBar()
    }
    
    func heritageTabBar() -> HeritagesTabBarController {

        let didSelect: DidSelect = { [weak self] heritage, type in
            guard let strongSelf = self else { return }
            let heritageViewController = strongSelf.heritageViewController(heritage: heritage, ofType: type)
            strongSelf.navigationController.pushViewController(heritageViewController, animated: true)
        }

        let heritageTabBarViewModel = HeritagesTabBarViewModel(heritageService: service, items: items)
        let tabController = HeritagesTabBarController(theme: theme,
                                                      tabBarViewModel: heritageTabBarViewModel,
                                                      didSelect: didSelect,
                                                      saveResults: saveResults)
        tabController.tabBar.isTranslucent = true
        tabController.tabBar.barTintColor = theme.tabBarBackgroundColor
        tabController.tabBar.tintColor = theme.tabBarTintColor

        return tabController
    }

    func heritageViewController(heritage: Heritage, ofType type: HeritageType) -> HeritageViewController {
        let isEnabled = type != .intangible ? true : false
        let heritageViewController = HeritageViewController(theme: theme,
                                                            heritage: heritage,
                                                            footerEnabled: isEnabled) { [weak self] title, location in
            guard let strongSelf = self else { return }
            let mapViewController = MapViewController(markerTitle: title, location: location)
            strongSelf.navigationController.pushViewController(mapViewController, animated: true)
        }
        return heritageViewController
    }
}
