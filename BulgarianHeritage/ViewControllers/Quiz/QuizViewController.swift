//
//  QuizViewController.swift
//  BulgarianCulture
//
//  Created by Teodor Evgeniev Yanev on 21.04.19.
//  Copyright © 2019 Stamsoft. All rights reserved.
//

import UIKit
import RxSwift
import RxSwiftExt
import Localize_Swift

class QuizViewController: UIViewController {
    typealias StartQuiz = (QuizQAResponse) -> Void

    private let disposeBag = DisposeBag()

    private let theme: Theme
    private let viewModel: QuizViewModelType
    private let startQuiz: StartQuiz?

    @IBOutlet weak var quizButton: ColorStyledButton!
    @IBOutlet weak var textLabel: UILabel!

    public init(theme: Theme, viewModel: QuizViewModelType, startQuiz: StartQuiz? = nil) {
        self.theme = theme
        self.viewModel = viewModel
        self.startQuiz = startQuiz
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        brand()
        localize()
        bindInputs()
        bindOutputs()
        quizButton.makeCornersRound()
        viewModel.inputs.viewDidLoad()
        // Do any additional setup after loading the view.
    }
}

extension QuizViewController {

    private func brand() {
        view.backgroundColor = theme.mainViewBackgroundColor
        textLabel.textColor = theme.mainLabelColor
        quizButton.applyMainButtonStyle(theme: theme)
    }
    
    private func localize() {
        textLabel.text = "It's about Bulgaria - this short earthly paradise - this place, where four years of history are interwoven, in which cultures and civilizations meet over the centuries of existence, glorious with their great heroes - all this can only help us feel proud BULGARIANS.\nThe World Cultural and Natural Heritage List of UNESCO includes a total of 9 Bulgarian cultural and nature sites. It also includes 3 intangible ones.\nIf you feel ready for the quiz, you can click on the \"Start Quiz\" button. an adverse case offer Have a look at the Bulgarian heritage materials in the \"All Heritage\" section of the menu. Good luck!".localized()
        quizButton.setTitle("Start quiz".localized(), for: .normal)
    }

    private func bindInputs() {
        quizButton.rx.tap
            .withUnretained(self)
            .asNoErrorDriver()
            .drive(onNext: { (weakSelf, _) in
                weakSelf.viewModel.inputs.quizButtonPressed()
            })
            .disposed(by: disposeBag)
    }
    
    private func bindOutputs() {
        viewModel.outputs.quizError
            .drive(onNext: showAlertError(message:))
            .disposed(by: disposeBag)
        
        viewModel.outputs.quizStart
            .withUnretained(self)
            .drive(onNext: { (weakSelf, quizQA) in
                weakSelf.startQuiz?(quizQA)
            })
            .disposed(by: disposeBag)
    }
    
    private func showAlertError(message errorMessage: (String)) {
        let alert = UIAlertController.init(title: "Alert".localized(),
                                           message: errorMessage,
                                           preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "OK".localized(), style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
