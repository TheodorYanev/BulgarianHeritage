//
//  LoginViewModel.swift
//  BulgarianCulture
//
//  Created by Teodor Evgeniev Yanev on 1.05.19.
//  Copyright © 2019 Stamsoft. All rights reserved.
//

import Foundation
import Localize_Swift
import RxSwiftExt
import RxSwift
import RxCocoa

protocol ILoginService {
    func checkUserExisting(for parameters: UserParameters, completion: @escaping NetworkCallback<[UserResponse]>)
}

protocol LoginViewModelInputs {
    func loginButtonPressed()
    func usernameChanged(name: String?)
    func passwordChanged(password: String?)
}

protocol LoginViewModelOutputs {
    var usernameError: Driver<String?> { get }
    var passwordError: Driver<String?> { get }
    var invalidErrorLabelIsHidden: Driver<Bool> { get }
    var invalidErrorLabelText: Driver<String?> { get }
    var loginButtonIsEnabled: Driver<Bool> { get }
    var loginCompleted: Driver<(String, String)> { get }
}

protocol LoginViewModelType {
    var inputs: LoginViewModelInputs { get }
    var outputs: LoginViewModelOutputs { get }
}

private enum State {
    case notSent
    case checking(String, String)
    case available
    case alreadyInUse(String)
}

class LoginViewModel: LoginViewModelType, LoginViewModelInputs, LoginViewModelOutputs {

    private let disposeBag = DisposeBag()

    private let usernameChangedSubject = BehaviorSubject<String?>(value: nil)
    private let passwordChangedSubject = BehaviorSubject<String?>(value: nil)
    private let invalidErrorLabelIsHiddenSubject = BehaviorSubject<Bool>(value: false)
    private let invalidErrorLabelTextSubject = BehaviorSubject<String?>(value: nil)
    private let loginButtonPressedSubject = PublishSubject<Void>()
    private let loginButtonIsEnabledSubject = BehaviorSubject<Bool>(value: false)

    var inputs: LoginViewModelInputs { return self }
    var outputs: LoginViewModelOutputs { return self }

    var usernameError: Driver<String?>
    var passwordError: Driver<String?>
    var invalidErrorLabelIsHidden: Driver<Bool>
    var invalidErrorLabelText: Driver<String?>
    var loginButtonIsEnabled: Driver<Bool>
    var loginCompleted: Driver<(String, String)>

    private var state = State.notSent {
        didSet {
            update(state)
        }
    }

    init(_ loginService: ILoginService) {

        let usernameWithValidator = usernameChangedSubject
            .asDriver(onErrorJustReturn: nil)
            .distinctUntilChanged()
            .map({ (username) in
                return (UsernameValidator(username: username), username)
            })

        let passwordWithValidator = passwordChangedSubject
            .asDriver(onErrorJustReturn: nil)
            .distinctUntilChanged()
            .map({ (password) in
                return (PasswordValidator(password: password), password)
            })

        usernameError = usernameWithValidator
            .map({ (validator, username) -> String? in
                guard validator.isValid || (username ?? "").isEmpty else {
                    return validator.rawValue.localized()
                }
                return nil
            })
            .distinctUntilChanged()

        passwordError = passwordWithValidator
            .map({ (validator, password) -> String? in
                guard validator.isValid || (password ?? "").isEmpty else {
                    return validator.rawValue.localized()
                }
                return nil
            })
            .distinctUntilChanged()

        loginButtonIsEnabled = loginButtonIsEnabledSubject
            .asDriver(onErrorJustReturn: false)
            .distinctUntilChanged()

        invalidErrorLabelText = invalidErrorLabelTextSubject
            .asDriver(onErrorJustReturn: nil)
            .distinctUntilChanged()

        invalidErrorLabelIsHidden = invalidErrorLabelIsHiddenSubject
            .asDriver(onErrorJustReturn: false)
            .distinctUntilChanged()

        let loginCompletedSubject = PublishSubject<(String, String)>()
        loginCompleted = loginCompletedSubject
            .asDriver(onErrorJustReturn: ("", ""))

        let usernameWithValidatorObservable = usernameWithValidator
            .asObservable()

        let passwordWithValidatorObservable = passwordWithValidator
            .asObservable()

        let usernameAndPasswordWithValidator = Observable
            .combineLatest(usernameWithValidatorObservable, passwordWithValidatorObservable, resultSelector: {
                (usernameWithValidator, passwordWithValidator) -> (UsernameValidator, String?, PasswordValidator, String?) in
                return (
                    usernameWithValidator.0,
                    usernameWithValidator.1,
                    passwordWithValidator.0,
                    passwordWithValidator.1
                )
            })
            .withUnretained(self)
            .asNoErrorDriver()

        usernameAndPasswordWithValidator
            .drive(onNext: { (weakSelf, _) in
                weakSelf.state = .notSent
            })
            .disposed(by: disposeBag)

        let usernameAndPasswordWithValidatorAndDebounce = usernameAndPasswordWithValidator
            .map({ (_, usernameAndPasswordWithValidator) -> (UsernameValidator, String?, PasswordValidator, String?) in
                return usernameAndPasswordWithValidator
            })
            .debounce(1.0)

        let checkUserExisting = usernameAndPasswordWithValidatorAndDebounce
            .distinctUntilChanged({ (nickNameAndPasswordWithValidation1, nickNameAndPasswordWithValidation2) -> Bool in
                let nickname1 = nickNameAndPasswordWithValidation1.1
                let nickname2 = nickNameAndPasswordWithValidation2.1
                let password1 = nickNameAndPasswordWithValidation1.3
                let password2 = nickNameAndPasswordWithValidation2.3
                return nickname1 == nickname2 && password1 == password2
            })
            .filter({ (usernameValidator, _, passwordValidator, _) -> Bool in
                return usernameValidator.isValid && passwordValidator.isValid
            })
            .map { (_, username, _, password) -> (String, String) in
                return (username!, password!)
        }

        checkUserExisting
            .withUnretained(self)
            .drive(onNext: { (weakSelf, usernameAndPassword) in
                let (username, password) = usernameAndPassword
                weakSelf.state = .checking(username, password)
                let userParameters = UserParameters(username: username, password: password)

                loginService.checkUserExisting(for: userParameters, completion: { (response) in
                    let currentUsername = try? weakSelf.usernameChangedSubject.value()// weakSelf or self?
                    let currentPassword = try? weakSelf.passwordChangedSubject.value()// weakSelf or self?
                    guard case let .checking(newUsername, newPassword) = weakSelf.state,
                        newUsername == currentUsername,
                        newPassword == currentPassword else { return }

                    switch response {
                    case .successful(value: let userResponse):
                        if !userResponse.isEmpty {
                            weakSelf.state = .available
                        } else {
                            weakSelf.state = .alreadyInUse("Wrong username or password! Try another combination.".localized())
                        }
                    case .failed(error: let networkError):
                        weakSelf.state = .alreadyInUse(networkError.error ?? "Error occurred! There would be a problem with the connection to the internet or to the server.".localized())
                    }
                })
            })
            .disposed(by: disposeBag)

        let usernameAndPassword = Observable
            .combineLatest(usernameChangedSubject, passwordChangedSubject)
        
        loginButtonPressedSubject
            .withLatestFrom(usernameAndPassword, resultSelector: { (_, usernameAndPassword) -> (String, String) in
                return (usernameAndPassword.0!, usernameAndPassword.1!)
            })
            .subscribe(onNext: { (username, password) in
                loginCompletedSubject.onNext((username, password))
            })
            .disposed(by: disposeBag)
    }
}

extension LoginViewModel {
    func loginButtonPressed() {
        loginButtonPressedSubject.onNext(())
    }

    func usernameChanged(name: String?) {
        usernameChangedSubject.onNext(name)
    }

    func passwordChanged(password: String?) {
        passwordChangedSubject.onNext(password)
    }
}

extension LoginViewModel {
    private func update(_ state: State) {
        switch state {
        case .notSent:
            invalidErrorLabelIsHiddenSubject.onNext(true)
            loginButtonIsEnabledSubject.onNext(false)
        case .checking:
            invalidErrorLabelTextSubject.onNext("Checking ...".localized())
            invalidErrorLabelIsHiddenSubject.onNext(false)
            loginButtonIsEnabledSubject.onNext(false)
        case .available:
            invalidErrorLabelIsHiddenSubject.onNext(true)
            loginButtonIsEnabledSubject.onNext(true)
        case .alreadyInUse(let message):
            invalidErrorLabelTextSubject.onNext(message)
            invalidErrorLabelIsHiddenSubject.onNext(false)
            loginButtonIsEnabledSubject.onNext(false)
        }
    }
}
