import Foundation
import RxSwift
import RxCocoa

class  TeamInfoRegistViewController: UIViewController {
    
    private var viewModel: TeamInfoRegistViewModel?
    private let disposeBag = DisposeBag()
    private let gradeDoneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: nil)
    private let sportsKindDoneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: nil)
    
    private lazy var ui: TeamInfoRegistUI = {
        let ui = TeamInfoRegistUIImpl()
        ui.viewController = self
        ui.teamIdField.delegate = self
        return ui
    }()
    
    private lazy var routing: TeamInfoRegistRouting = {
        let routing = TeamInfoRegistRoutingImpl()
        routing.viewController = self
        return routing
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ui.setup(storeName: R.string.locarizable.team_info_title())
        viewModel = TeamInfoRegistViewModel(teamIdField: ui.teamIdField.rx.text.orEmpty.asDriver(), gradeField: ui.gradeField.rx.text.orEmpty.asDriver(), sportsKindField: ui.sportsKindField.rx.text.orEmpty.asDriver())
        setupViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ui.gradeToolBar.items = [gradeDoneButton]
        ui.sportsKindToolBar.items = [sportsKindDoneButton]
        ui.setupToolBar(ui.gradeField, type: .grade, toolBar: ui.gradeToolBar, content: viewModel?.outputs.gradeArr ?? [R.string.locarizable.empty()], vc: self)
        ui.setupToolBar(ui.sportsKindField, type: .sports, toolBar: ui.sportsKindToolBar, content: viewModel?.outputs.sportsKindArr ?? [R.string.locarizable.empty()], vc: self)
    }
}

extension TeamInfoRegistViewController {
    
    private func setupViewModel() {
        viewModel?.outputs.isNextBtnEnable.asObservable()
            .subscribe(onNext: { [weak self] isValid in
                print(isValid)
                self?.ui.nextBtn.isHidden = !isValid
            }).disposed(by: disposeBag)

        ui.nextBtn.rx.tap.asObservable()
            .throttle(1, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.ui.nextBtn.bounce(completion: {
                    self?.routing.RepresentMemberRegister()
                })
            }).disposed(by: disposeBag)
        
        gradeDoneButton.rx.tap
            .throttle(0.5, scheduler: MainScheduler.instance)
            .bind { [weak self] _ in
                if let _ = self?.ui.gradeField.isFirstResponder {
                    self?.ui.gradeField.resignFirstResponder()
                }
            }.disposed(by: disposeBag)
        
        sportsKindDoneButton.rx.tap
            .throttle(0.5, scheduler: MainScheduler.instance)
            .bind { [weak self] _ in
                if let _ = self?.ui.sportsKindField.isFirstResponder {
                    self?.ui.sportsKindField.resignFirstResponder()
                }
            }.disposed(by: disposeBag)
    }
}

extension TeamInfoRegistViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return TeamInfoRegisterResources.View.pickerNumberOfComponents
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case is GradePickerView: return viewModel?.outputs.gradeArr.count ?? 0
        case is SportsKindPickerView: return viewModel?.outputs.sportsKindArr.count ?? 0
        default: return 0
        }
    }
}

extension TeamInfoRegistViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case is GradePickerView: return viewModel?.outputs.gradeArr[row] ?? R.string.locarizable.empty()
        case is SportsKindPickerView: return viewModel?.outputs.sportsKindArr[row] ?? R.string.locarizable.empty()
        default: return Optional<String>("")
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case is GradePickerView: ui.gradeField.text = viewModel?.outputs.gradeArr[row]
        case is SportsKindPickerView: ui.sportsKindField.text = viewModel?.outputs.sportsKindArr[row]
        default: break
        }
    }
}

extension TeamInfoRegistViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}
