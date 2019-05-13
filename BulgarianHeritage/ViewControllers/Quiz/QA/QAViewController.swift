//
//  Q&AViewController.swift
//  PAM
//
//  Created by Teodor Evgeniev Yanev on 14.08.18.
//  Copyright © 2018 Stamsoft. All rights reserved.
//

import UIKit
import Localize_Swift

class QAViewController: UIViewController {
    typealias NextQuestion = ([Question], Int) -> Void
    typealias ShowScore = ([Question]) -> Void
    
    let questionIndex: Int
    var questions: [Question]
    private let theme: Theme
    //private var question: Question
    private var lastCell: IndexPath?
    private let nextQuestion: NextQuestion?
    private let showScore: ShowScore?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var nextButton: ColorStyledButton!
    
    @IBAction func nextAction(_ sender: ColorStyledButton) {
        if questionIndex < questions.count - 1 {
            nextQuestion?(questions, questionIndex + 1)
        } else if questionIndex == questions.count - 1 {
            showScore?(questions)
        }
    }
    
    public init(theme: Theme,
                questions: [Question],
                for index: Int,
                nextQuestion: NextQuestion? = nil,
                showScore: ShowScore? = nil) {
        self.theme = theme
        self.questions = questions
        self.questionIndex = index
        //self.question = self.questions[self.questionIndex]
        self.nextQuestion = nextQuestion
        self.showScore = showScore
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        brand()
        localize()
        nextButton.isEnabled = false
        tableView.register(cellClass: QATableViewCell.self)
        let backBarButtonItem = UIBarButtonItem(title: "   ", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backBarButtonItem
    }
    
    private func brand() {
        view.backgroundColor = theme.mainViewBackgroundColor
        tableView.backgroundColor = theme.tableViewBackgroundColor
        questionLabel.text = questions[questionIndex].text
        questionLabel.textColor = theme.mainLabelColor
        nextButton.applyMainButtonStyle(theme: theme)
    }
    
    private func localize() {
        title = "\(questionIndex + 1)" + " of ".localized() + "\(questions.count)"
        nextButton.setTitle("Next".localized(), for: .normal)
    }
}
extension QAViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
extension QAViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questions[questionIndex].answers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let answer = questions[questionIndex].answers[indexPath.row]
        let cell = tableView.dequeueReusableCell(for: indexPath) as QATableViewCell
        cell.answerLabel.textColor = theme.tableViewCellTextColor
        cell.backgroundColor = theme.tableViewCellBackgroundColor
        cell.answerButton.backgroundColor = theme.tableViewCellButtonBackgroundColor
        cell.answerLabel.text = answer.text
        cell.answerButton.isSelected = false
        cell.delegate = self
        return cell
    }
}

extension QAViewController: QATableViewCellDelegate {
    func qaTableViewCell(_ qaTableViewCell: QATableViewCell, didSelect radioButton: RadioButton) {
        let currentIndexPath = tableView.indexPath(for: qaTableViewCell)
        if let lastIndexPath = lastCell,
            let lastSelectedCell = tableView.cellForRow(at: lastIndexPath) as? QATableViewCell,
            let currentRow = currentIndexPath?.row,
            lastIndexPath.row != currentRow {
            lastSelectedCell.answerButton.isSelected = false
        }
        lastCell = currentIndexPath
        radioButton.isSelected = !radioButton.isSelected
        guard let selectedRow = lastCell?.row else {
            print("The Cell with that index path does not exist\n")
            return
        }
        let answer_id = radioButton.isSelected ? questions[questionIndex].answers[selectedRow].id : nil
        questions[questionIndex].answer_id = answer_id
        print(questions[questionIndex].answers)
        nextButton.isEnabled = questions[questionIndex].answer_id != nil
    }
}

