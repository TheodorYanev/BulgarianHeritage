//
//  ScoresViewController.swift
//  BulgarianCulture
//
//  Created by Teodor Evgeniev Yanev on 10.05.19.
//  Copyright © 2019 Stamsoft. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxSwiftExt
import RxDataSources
import Localize_Swift

class ScoresViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    
    private let theme: Theme
    private let viewModel: ScoresViewModelType
    
    init(theme: Theme, viewModel: ScoresViewModelType) {
        self.theme = theme
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBOutlet var titleLabelsCollection: [UILabel]!
    @IBOutlet weak var positionTitleLabel: UILabel!
    @IBOutlet weak var usernameTitleLabel: UILabel!
    @IBOutlet weak var scoreTitleLabel: UILabel!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        brand()
        localize()
        bindOutputs()
        lineView.frame.size.height = 3.0
        tableView.register(cellClass: ScoresTableViewCell.self)
        viewModel.inputs.viewDidLoad()
    }
}

extension ScoresViewController {

    private func brand() {
        for titleLabel in titleLabelsCollection {
            titleLabel.textColor = theme.mainLabelColor
        }
        lineView.backgroundColor = theme.lineColor
        tableView.separatorColor = theme.lineColor
    }
    
    private func localize() {
        positionTitleLabel.text = "Position".localized()
        usernameTitleLabel.text = "Username".localized()
        scoreTitleLabel.text = "Score".localized()
    }
    
    private func bindOutputs() {
        let theme = self.theme
        let dataSource = RxTableViewSectionedReloadDataSource<SectionOfScores>
            .init(configureCell: { (_, tableView, indexPath, score) -> UITableViewCell in
                let cell = tableView.dequeueReusableCell(for: indexPath) as ScoresTableViewCell
                cell.positionLabel.text = String(indexPath.row + 1)
                cell.usernameLabel.text = score.username
                cell.scoreLabel.text = String(score.score)
                
                for label in cell.labelsCollection {
                    label.textColor = theme.mainLabelColor
                }
                cell.backgroundColor = theme.tableViewCellBackgroundColor
                
                return cell
            })
        
        viewModel.outputs.scores.asObservable()
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        viewModel.outputs.fetchError
            .drive(onNext: showAlertError(message:))
            .disposed(by: disposeBag)
        viewModel.outputs.fetchRequestStatus
            .drive(rx.requestResult)
            .disposed(by: disposeBag)
    }
    
    private func showAlertError(message errorMessage: (String)) {
        let alert = UIAlertController(title: "Error".localized(),
                                      message: errorMessage,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "Ok".localized(), style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
