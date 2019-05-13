//
//  RegistrationViewModel.swift
//  BulgarianCulture
//
//  Created by Teodor Evgeniev Yanev on 26.04.19.
//  Copyright © 2019 Stamsoft. All rights reserved.
//

import Foundation
import Localize_Swift
import RxSwiftExt
import RxSwift
import RxCocoa

protocol IRegistrationService {
    func checkUserExisting(for parameters: UserParameters, completion: @escaping NetworkCallback<[UserResponse]>)
    func register(with parameters: UserRegistrationParameters, completion: @escaping NetworkCallback<Bool>)
}

protocol RegistrationViewModelInputs {
    func registrationButtonPressed()
    func usernameChanged(name: String?)
    func passwordChanged(password: String?)
}

protocol RegistrationViewModelOutputs {

    var registrationButtonIsEnabled: Driver<Bool> { get }
    var registrationRequestStatus: Driver<RequestResult> { get }
    var registrationError: Driver<String> { get }
    var registrationCompleted: Driver<(String, String)> { get }
    var usernameError: Driver<String?> { get }
    var passwordError: Driver<String?> { get }
    var userAlreadyInUseErrorLabelIsHidden: Driver<Bool> { get }
    var userAlreadyInUseErrorLabelText: Driver<String?> { get }
}

protocol RegistrationViewModelType {
    var inputs: RegistrationViewModelInputs { get }
    var outputs: RegistrationViewModelOutputs { get }
}


private enum State {
    case notSent
    case checking(String, String)
    case available
    case alreadyInUse(String)
}

class RegistrationViewModel: RegistrationViewModelType, RegistrationViewModelInputs, RegistrationViewModelOutputs {

    private let disposeBag = DisposeBag()
    
    private let usernameChangedSubject = BehaviorSubject<String?>(value: nil)
    private let passwordChangedSubject = BehaviorSubject<String?>(value: nil)
    private let registrationButtonPressedSubject = PublishSubject<Void>()
    private let registrationButtonIsEnabledSubject = BehaviorSubject<Bool>(value: false)
    private let userAlreadyInUseErrorLabelIsHiddenSubject = BehaviorSubject<Bool>(value: false)
    private let userAlreadyInUseErrorLabelTextSubject = BehaviorSubject<String?>(value: nil)

    var inputs: RegistrationViewModelInputs { return self }
    var outputs: RegistrationViewModelOutputs { return self }

    var usernameError: Driver<String?>
    var passwordError: Driver<String?>
    var registrationButtonIsEnabled: Driver<Bool>
    var registrationRequestStatus: Driver<RequestResult>
    var userAlreadyInUseErrorLabelIsHidden: Driver<Bool>
    var userAlreadyInUseErrorLabelText: Driver<String?>
    var registrationCompleted: Driver<(String, String)>
    var registrationError: Driver<String>

    private var state = State.notSent {
        didSet {
            update(state)
        }
    }

    init(_ registrationService: IRegistrationService) {

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

        registrationButtonIsEnabled = registrationButtonIsEnabledSubject
            .asDriver(onErrorJustReturn: false)
            .distinctUntilChanged()
        
        userAlreadyInUseErrorLabelText = userAlreadyInUseErrorLabelTextSubject
            .asDriver(onErrorJustReturn: nil)
            .distinctUntilChanged()

        userAlreadyInUseErrorLabelIsHidden = userAlreadyInUseErrorLabelIsHiddenSubject
            .asDriver(onErrorJustReturn: false)
            .distinctUntilChanged()

        let registrationRequestStatusSubject = BehaviorSubject<RequestResult>(value: .notStarted)
        registrationRequestStatus = registrationRequestStatusSubject
            .asDriver(onErrorJustReturn: .notStarted)
            .distinctUntilChanged()

        let registrationCompletedSubject = PublishSubject<(String, String)>()
        registrationCompleted = registrationCompletedSubject
            .asDriver(onErrorJustReturn: ("", ""))

        let registrationErrorSubject = PublishSubject<String>()
        registrationError = registrationErrorSubject
            .asDriver(onErrorJustReturn: "")
            .delay(2.0)

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

                registrationService.checkUserExisting(for: userParameters, completion: { (response) in
                    let currentUsername = try? weakSelf.usernameChangedSubject.value()// weakSelf or self?
                    let currentPassword = try? weakSelf.passwordChangedSubject.value()// weakSelf or self?
                    guard case let .checking(newUsername, newPassword) = weakSelf.state,
                        newUsername == currentUsername,
                        newPassword == currentPassword else { return }

                    switch response {
                    case .successful(value: let userResponse):
                        if userResponse.isEmpty {
                            weakSelf.state = .available
                        } else {
                            weakSelf.state = .alreadyInUse("These username and password are already in use! Try another combination.".localized())
                        }
                    case .failed(error: let networkError):
                        weakSelf.state = .alreadyInUse(networkError.error ?? "Error occurred! There would be a problem with the connection to the internet or to the server.".localized())
                    }
                })
            })
            .disposed(by: disposeBag)

        let usernameAndPassword = Observable
            .combineLatest(usernameChangedSubject, passwordChangedSubject)

        registrationButtonPressedSubject
            .withLatestFrom(usernameAndPassword, resultSelector: { (_, usernameAndPassword) -> (String, String) in
                return (usernameAndPassword.0!, usernameAndPassword.1!)
            })
            .subscribe(onNext: { (username, password) in
                registrationRequestStatusSubject.onNext(.inProgress(message: nil))
                let usernameParameters = UserRegistrationParameters(username: username, password: password, id: UUID.init())
                registrationService.register(with: usernameParameters) { (result) in
                    switch result {
                    case .successful:
                        registrationCompletedSubject.onNext((username, password))
                        registrationRequestStatusSubject.onNext(.success(message: "Registration completed".localized()))
                    case .failed(let error):
                        registrationErrorSubject.onNext(error.error ?? "There is a problem with the internet or server connection.")
                        registrationRequestStatusSubject.onNext(.error(message: error.error ?? "Registration failed!".localized()))
                    }
                }
            })
            .disposed(by: disposeBag)
    }
}

extension RegistrationViewModel {

    func registrationButtonPressed() {
        registrationButtonPressedSubject.onNext(())
    }

    func usernameChanged(name: String?) {
        usernameChangedSubject.onNext(name)
    }

    func passwordChanged(password: String?) {
        passwordChangedSubject.onNext(password)
    }
}

extension RegistrationViewModel {
    private func update(_ state: State) {
        switch state {
        case .notSent:
            userAlreadyInUseErrorLabelIsHiddenSubject.onNext(true)
            registrationButtonIsEnabledSubject.onNext(false)
        case .checking:
            userAlreadyInUseErrorLabelTextSubject.onNext("Checking ...".localized())
            userAlreadyInUseErrorLabelIsHiddenSubject.onNext(false)
            registrationButtonIsEnabledSubject.onNext(false)
        case .available:
            userAlreadyInUseErrorLabelIsHiddenSubject.onNext(true)
            registrationButtonIsEnabledSubject.onNext(true)
        case .alreadyInUse(let message):
            userAlreadyInUseErrorLabelTextSubject.onNext(message)
            userAlreadyInUseErrorLabelIsHiddenSubject.onNext(false)
            registrationButtonIsEnabledSubject.onNext(false)
        }
    }
}
