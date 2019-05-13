//
//  HeritagesTabBarController.swift
//  BulgarianCulture
//
//  Created by Teodor Evgeniev Yanev on 5.05.19.
//  Copyright © 2019 Stamsoft. All rights reserved.
//

import UIKit
import RxSwift
import RxSwiftExt
import Localize_Swift

class HeritagesTabBarController: UITabBarController {
    typealias SaveResults = (HeritagesResponse) -> ()
    typealias DidSelect = (Heritage, HeritageType) -> ()

    private let saveResults: SaveResults?
    private let didSelect: DidSelect?

    private let theme: Theme
    private let disposeBag = DisposeBag()
    private let viewModel: HeritagesTabBarViewModelType

    init(theme: Theme,
         tabBarViewModel: HeritagesTabBarViewModelType,
         didSelect: DidSelect? = nil,
         saveResults: SaveResults? = nil) {

        self.theme = theme
        self.viewModel = tabBarViewModel
        self.didSelect = didSelect
        self.saveResults = saveResults

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.inputs.viewDidLoad()
        bindOutputs()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        viewModel.inputs.viewDidLoad()
    }
}

extension HeritagesTabBarController {

    private func bindOutputs() {
        viewModel.outputs.fetchRequestStatus
            .drive(self.rx.requestResult).disposed(by: disposeBag)
        
        viewModel.outputs.fetchError
            .drive(onNext: showAlertError(message:))
            .disposed(by: disposeBag)

        viewModel.outputs.fetchCompleted
            .drive(onNext: fetchCompleted(heritages:))
            .disposed(by: disposeBag)
    }
    
    private func showAlertError(message errorMessage: String) {
        let alert = UIAlertController.init(title: "Error".localized(),
                                           message: errorMessage,
                                           preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "OK".localized(), style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func fetchCompleted(heritages: HeritagesResponse?) {
        self.viewControllers = self.heritagesViewController(items: heritages)
        guard let heritages = heritages else { return }
        self.saveResults?(heritages)
    }

}

extension HeritagesTabBarController {
    private func heritagesViewController(items: HeritagesResponse?) -> [HeritagesViewController] {
        var controllers: [HeritagesViewController] = []

        let culturalHeritageViewController = HeritagesViewController(theme: theme,
                                                                     type: .cultural,
                                                                     items: items?.culturalHeritages,
                                                                     didSelect: didSelect)
        culturalHeritageViewController.tabBarItem = UITabBarItem(title: "Cultural".localized(),
                                                                 image: UIImage(named: "CulturalHeritage"),
                                                                 selectedImage: nil)

        let naturalHeritageViewController = HeritagesViewController(theme: theme,
                                                                    type: .natural,
                                                                    items: items?.naturalHeritages,
                                                                    didSelect: didSelect)
        naturalHeritageViewController.tabBarItem = UITabBarItem(title: "Natural".localized(),
                                                                image: UIImage(named: "NaturalHeritage"),
                                                                selectedImage: nil)

        let intangibleHeritageViewController = HeritagesViewController(theme: theme,
                                                                        type: .intangible,
                                                                        items: items?.intangibleHeritages,
                                                                        didSelect: didSelect)
        intangibleHeritageViewController.tabBarItem = UITabBarItem(title: "Intangible".localized(),
                                                                    image: UIImage(named: "NonMaterialHeritage"),
                                                                    selectedImage: nil)
        controllers.append(culturalHeritageViewController)
        controllers.append(naturalHeritageViewController)
        controllers.append(intangibleHeritageViewController)

        return controllers
    }
}
