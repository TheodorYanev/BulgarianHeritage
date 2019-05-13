//
//  LoginViewController.swift
//  BulgarianCulture
//
//  Created by Teodor Evgeniev Yanev on 1.05.19.
//  Copyright © 2019 Stamsoft. All rights reserved.
//

import UIKit
import RxSwift
import RxSwiftExt
import SkyFloatingLabelTextField
import Localize_Swift

class LoginViewController: UIViewController {
    typealias CreateAccount = () -> Void
    typealias Login = (String, String) -> Void

    private let createAccount: CreateAccount!
    private let login: Login?

    private let viewModel: LoginViewModelType
    private let disposeBag = DisposeBag()
    private let theme: Theme

    @IBOutlet weak var usernameTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var passwordTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var invalidErrorLabel: UILabel!
    @IBOutlet weak var loginButton: ColorStyledButton!

    @IBAction func createAccountPressed(_ sender: UIButton) {
        createAccount?()
    }

    init(viewModel: LoginViewModelType,
         theme: Theme,
         createAccount: CreateAccount? = nil,
         login: Login? = nil) {
        self.viewModel = viewModel
        self.theme = theme
        self.createAccount = createAccount
        self.login = login
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
        loginButton.makeCornersRound()
    }
}

extension LoginViewController {
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
        
        loginButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { (weakSelf, _) in
                weakSelf.viewModel.inputs.loginButtonPressed()
            })
            .disposed(by: disposeBag)
    }
    
    func bindOutputs() {
        viewModel.outputs.usernameError
            .drive(usernameTextField.rx.errorMessage).disposed(by: disposeBag)
        viewModel.outputs.passwordError
            .drive(passwordTextField.rx.errorMessage).disposed(by: disposeBag)
        viewModel.outputs.loginButtonIsEnabled
            .drive(loginButton.rx.isEnabled).disposed(by: disposeBag)
        viewModel.outputs.invalidErrorLabelIsHidden
            .drive(invalidErrorLabel.rx.isHidden).disposed(by: disposeBag)
        viewModel.outputs.invalidErrorLabelText
            .drive(invalidErrorLabel.rx.text).disposed(by: disposeBag)
        
        viewModel.outputs.loginCompleted
            .withUnretained(self)
            .drive(onNext: { (weakSelf, usernameAndPassword) in
                let username = usernameAndPassword.0
                let password = usernameAndPassword.1
                weakSelf.login?(username, password)
            })
            .disposed(by: disposeBag)
    }
    
    func brand() {
        view.backgroundColor = theme.mainViewBackgroundColor
        usernameTextField.textColor = theme.textColor
        usernameTextField.lineColor =  theme.lineColor
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
        createAccountButton.setTitleColor(theme.hintLabelColor, for: .normal)
        invalidErrorLabel.textColor = theme.errorTextColor
        loginButton.applyMainButtonStyle(theme: theme)
        loginButton.setTitle("Login".localized(), for: .normal)
    }
    
    func localize() {
        title = "Login".localized()
        usernameTextField.selectedTitle = "username".localized()
        usernameTextField.placeholder = "username".localized()
        passwordTextField.selectedTitle = "password".localized()
        passwordTextField.placeholder = "password".localized()
        createAccountButton.setTitle("Create new account".localized(), for: .normal)
    }
}
