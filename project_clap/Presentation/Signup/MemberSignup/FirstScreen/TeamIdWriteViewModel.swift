import Foundation
import RxSwift
import RxCocoa

protocol TeamIdWriteViewModelInput {
    var teamIdText: Observable<String> { get }
}

protocol TeamIdWriteViewModelOutput {
    var isConfirmBtnEnable: Observable<Bool> { get }
}

protocol TeamIdWriteViewModelType {
    var inputs: TeamIdWriteViewModelInput { get }
    var outputs: TeamIdWriteViewModelOutput { get }
}

final class TeamIdWriteViewModel: TeamIdWriteViewModelType, TeamIdWriteViewModelInput, TeamIdWriteViewModelOutput {
    var inputs: TeamIdWriteViewModelInput { return self }
    var outputs: TeamIdWriteViewModelOutput { return self }
    var teamIdText: Observable<String>
    var isConfirmBtnEnable: Observable<Bool>
    let disposeBag = DisposeBag()
    
    init(teamIdField: Observable<String>) {
        var value: TeamIdWriteValidationResult?
        teamIdText = teamIdField
        
        let isEmpty = Observable.combineLatest([teamIdText]) { teamId -> TeamIdWriteValidationResult in
            return TeamIdWriteValidation.validateEmpty(teamId: teamId[0])
        }
        .share(replay: 1)
        
        let isMatch = teamIdText.filter { text in
            text.count > 1
            }.map { text -> TeamIdWriteValidationResult in
                TeamIdWriteValidation().validMatch(teamId: text, completion: { result in
                    value = result
                })
                return value ?? .ok
                // なぜかvalueに値が入らない
            }.share(replay: 1)
        
        let isCount = Observable.combineLatest([teamIdText]) { teamId -> TeamIdWriteValidationResult in
            return TeamIdWriteValidation.validCharCount(teamId: teamId[0])
        }
        .share(replay: 1)
        
        isConfirmBtnEnable = Observable.combineLatest(isEmpty, isMatch, isCount) { (empty, match, count) in
            print("empty: \(empty)")
            print("match: \(match)")
            print("count: \(count)")
            return empty.isValid &&
            match.isValid &&
            count.isValid
        }
        .share(replay: 1)
    }
    
    func fetchBelongData(teamId: String, completion: @escaping (String?, Error?) -> Void) {
        SignupRepositoryImpl().fetchBelongData(teamId: teamId, completion: { belong in
            completion(belong ?? "", nil)
        })
    }
}
