//
//  QAScoreViewController.swift
//  BulgarianCulture
//
//  Created by Teodor Evgeniev Yanev on 7.05.19.
//  Copyright © 2019 Stamsoft. All rights reserved.
//

import UIKit
import RxSwift
import RxSwiftExt
import RxCocoa
import Localize_Swift

class QAScoreViewController: UIViewController {
    typealias Interrupted = () -> Void
    typealias Completed = () -> Void
    let disposeBag = DisposeBag()

    private let theme: Theme
    private let viewModel: QAScoreViewModel
    private let completed: Completed?
    private let interrupted: Interrupted?

    @IBOutlet weak var rulesLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var finishButton: ColorStyledButton!

    @IBAction func finishQuiz(_ sender: ColorStyledButton) {
        viewModel.inputs.finishQuizPressed()
    }

    init(theme: Theme, viewModel: QAScoreViewModel, completed: Completed? = nil, interrupted: Interrupted? = nil) {
        self.theme = theme
        self.viewModel = viewModel
        self.completed = completed
        self.interrupted = interrupted
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        brand()
        localize()
        bindOutputs()
        finishButton.makeCornersRound()
        viewModel.inputs.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Back to menu".localized(), style: .done, target: self, action: #selector(back(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
    }

    @objc func back(sender: UIBarButtonItem) {
        self.interrupted?()
    }
}

extension QAScoreViewController {

    private func brand() {
        view.backgroundColor = theme.mainViewBackgroundColor
        rulesLabel.textColor = theme.mainLabelColor
        scoreLabel.textColor = theme.mainLabelColor
        finishButton.applyMainButtonStyle(theme: theme)
    }
    
    private func localize() {
        title = "Result".localized()
        rulesLabel.text = "\nRules are:\nYou get 1 point for every correctly answered question.\nGrade scale is:\nFor 0 to 4 points - Failed(F)\nFor 5 to 7 points - Fine(D)\nFor 8 to 9 points - Good(C)\nFor 10 to 11 points - Very Good(B)\nFor 12 points - Excellent(A)".localized()
        finishButton.setTitle("Finish quiz".localized(), for: .normal)
    }
    
    private func bindOutputs() {
        viewModel.outputs.scoreLabelText
            .drive(scoreLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.outputs.quizScoreRequestStatus
            .drive(self.rx.requestResult)
            .disposed(by: disposeBag)
        
        viewModel.outputs.quizError
            .drive(onNext: showAlertError(message:))
            .disposed(by: disposeBag)
        
        viewModel.outputs.quizCompleted
            .withUnretained(self)
            .drive(onNext: { (weakSelf, _) in
                weakSelf.completed?()
            })
            .disposed(by: disposeBag)
    }
    
    private func showAlertError(message errorMessage: (String)) {
        let alert = UIAlertController.init(title: "Error".localized(),
                                           message: errorMessage,
                                           preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "OK".localized(), style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
}
