//
//  RegistrationViewController.swift
//  BulgarianCulture
//
//  Created by Teodor Evgeniev Yanev on 26.04.19.
//  Copyright © 2019 Stamsoft. All rights reserved.
//

import UIKit
import RxSwift
import RxSwiftExt
import SkyFloatingLabelTextField
import Localize_Swift

class RegistrationViewController: UIViewController {

    typealias Completed = ((String, String) -> Void)

    private let completed: Completed?

    private let viewModel: RegistrationViewModelType
    private let disposeBag = DisposeBag()
    private let theme: Theme

    @IBOutlet weak var usernameTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var passwordTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var alreadyInUseErrorLabel: UILabel!
    @IBOutlet weak var registerButton: ColorStyledButton!

    init(viewModel: RegistrationViewModelType,
         theme: Theme,
         completed: Completed? = nil) {
        self.viewModel = viewModel
        self.theme = theme
        self.completed = completed
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bindInputs()
        bindOutputs()
        brand()
        localize()
        registerButton.makeCornersRound()
    }
}
extension RegistrationViewController {

    func brand() {
        view.backgroundColor = theme.mainViewBackgroundColor
        usernameTextField.textColor = theme.textColor
        usernameTextField.lineColor = theme.lineColor
        usernameTextField.titleColor = theme.titleColor
        usernameTextField.selectedTitleColor = theme.selectedTitleColor
        usernameTextField.selectedLineColor = theme.selectedLineColor
        usernameTextField.errorColor = theme.errorColor
        usernameTextField.lineErrorColor = theme.errorColor
        usernameTextField.textErrorColor = theme.errorTextColor
        usernameTextField.placeholderColor = theme.placeHolderTextColor
        passwordTextField.textColor = theme.textColor
        passwordTextField.lineColor = theme.lineColor
        passwordTextField.titleColor = theme.titleColor
        passwordTextField.selectedTitleColor = theme.selectedTitleColor
        passwordTextField.selectedLineColor = theme.selectedLineColor
        passwordTextField.errorColor = theme.errorColor
        passwordTextField.lineErrorColor = theme.errorColor
        passwordTextField.textErrorColor = theme.errorTextColor
        passwordTextField.placeholderColor = theme.placeHolderTextColor
        infoLabel.textColor = theme.hintLabelColor
        alreadyInUseErrorLabel.textColor = theme.errorTextColor
        registerButton.applyMainButtonStyle(theme: StandardTheme())
        registerButton.setTitle("Register".localized(), for: .normal)
    }

    func localize() {
        title = "Registration".localized()
        usernameTextField.selectedTitle = "username".localized()
        usernameTextField.placeholder = "username".localized()
        passwordTextField.selectedTitle = "password".localized()
        passwordTextField.placeholder = "password".localized()
        infoLabel.text = "Username and password should start with word character and should be atleast 6 characters".localized()
    }

    func bindInputs() {
        usernameTextField.rx.text
            .withUnretained(self)
            .subscribe(onNext: { (weakSelf, text) in
                weakSelf.viewModel.inputs.usernameChanged(name: text)
            })
            .disposed(by: disposeBag)

        passwordTextField.rx.text
            .withUnretained(self)
            .subscribe(onNext: { (weakSelf, text) in
                weakSelf.viewModel.inputs.passwordChanged(password: text)
            })
            .disposed(by: disposeBag)

        registerButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { (weakSelf, _) in
                weakSelf.viewModel.inputs.registrationButtonPressed()
            })
            .disposed(by: disposeBag)
    }

    func bindOutputs() {
        viewModel.outputs.usernameError
            .drive(usernameTextField.rx.errorMessage)
            .disposed(by: disposeBag)
        viewModel.outputs.passwordError
            .drive(passwordTextField.rx.errorMessage)
            .disposed(by: disposeBag)
        viewModel.outputs.registrationButtonIsEnabled
            .drive(registerButton.rx.isEnabled)
            .disposed(by: disposeBag)
        viewModel.outputs.registrationRequestStatus
            .drive(self.rx.requestResult)
            .disposed(by: disposeBag)
        viewModel.outputs.userAlreadyInUseErrorLabelIsHidden
            .drive(alreadyInUseErrorLabel.rx.isHidden)
            .disposed(by: disposeBag)
        viewModel.outputs.userAlreadyInUseErrorLabelText
            .drive(alreadyInUseErrorLabel.rx.text)
            .disposed(by: disposeBag)
        viewModel.outputs.registrationError
            .drive(onNext: showAlertError(message:))
            .disposed(by: disposeBag)
        viewModel.outputs.registrationCompleted
            .withUnretained(self)
            .drive(onNext: { (weakSelf, usernameAndPassword) in
                let username = usernameAndPassword.0
                let password = usernameAndPassword.1
                weakSelf.completed?(username, password)
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
