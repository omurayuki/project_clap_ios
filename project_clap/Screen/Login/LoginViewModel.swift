import Foundation
import RxSwift
import RxCocoa

protocol LoginViewModelInput {
    var emailText:Driver<String> { get }
    var passText: Driver<String> { get }
}

protocol LoginViewModelOutput {
    var isLoginBtnEnable: Driver<Bool> { get }
}

protocol LoginViewModelType {
    var inputs: LoginViewModelInput { get }
    var outputs: LoginViewModelOutput { get }
}

struct LoginViewModel: LoginViewModelType, LoginViewModelInput, LoginViewModelOutput {
    var inputs: LoginViewModelInput { return self }
    var outputs: LoginViewModelOutput { return self }
    var emailText: Driver<String>
    var passText: Driver<String>
    var isLoginBtnEnable: Driver<Bool>
    let disposeBag = DisposeBag()
    
    init(emailField: Driver<String>, passField: Driver<String>, loginTapped: Driver<Void>) {
        emailText = emailField
        passText = passField
        
        let isEmpty = Driver.combineLatest(emailText, passText) { email, pass -> LoginValidationResult in
            LoginValidation.validateEmpty(email: email, pass: pass)
        }.asDriver()
        
        isLoginBtnEnable = Driver.combineLatest([isEmpty], { empty in
            empty[0].isValid
        }).asDriver()
    }
}
