import Foundation
import RxSwift
import RxCocoa

class MypageEditViewController: UIViewController {
    
    var recievedUid: String
    let activityIndicator = UIActivityIndicatorView()
    private var viewModel: MypageEditViewModel!
    
    private lazy var ui: MypageEditUI = {
        let ui = MypageEditUIImple()
        ui.viewController = self
        return ui
    }()
    
    private lazy var routing: MypageEditRouting = {
        let routing = MypageEditRoutingImpl()
        routing.viewController = self
        return routing
    }()
    
    init(uid: String) {
        recievedUid = uid
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ui.setup(vc: self)
        ui.setupInsideStack(vc: self)
        viewModel = MypageEditViewModel(belongField: ui.belongTeamField.rx.text.orEmpty.asObservable(),
                                        positionField: ui.positionField.rx.text.orEmpty.asObservable(),
                                        mailField: ui.mailField.rx.text.orEmpty.asObservable())
        ui.setupToolBar(ui.positionField,
                        toolBar: ui.positionToolBar,
                        content: viewModel?.outputs.positionArr ?? [R.string.locarizable.empty()],
                        vc: self)
        setupViewModel()
    }
}

extension MypageEditViewController {
    
    private func setupViewModel() {
        
        viewModel?.outputs.isSaveBtnEnable
            .subscribe(onNext: { [weak self] isValid in
                self?.ui.saveBtn.isHidden = !isValid
            }).disposed(by: viewModel.disposeBag)
        
        viewModel.outputs.isOverBelong
            .distinctUntilChanged()
            .subscribe(onNext: { bool in
                if bool {
                    self.ui.belongTeamField.backgroundColor = AppResources.ColorResources.appCommonClearOrangeColor
                    AlertController.showAlertMessage(alertType: .overChar, viewController: self)
                } else {
                    self.ui.belongTeamField.backgroundColor = .white
                }
            }).disposed(by: viewModel.disposeBag)
        
        ui.doneBtn.rx.tap
            .throttle(0.5, scheduler: MainScheduler.instance)
            .bind { [weak self] _ in
                if let _ = self?.ui.positionField.isFirstResponder {
                    self?.ui.positionField.resignFirstResponder()
                }
            }.disposed(by: viewModel.disposeBag)
        
        ui.saveBtn.rx.tap
            .bind(onNext: { [weak self] _ in
                self?.ui.saveBtn.bounce(completion: {
                    guard let this = self else { return }
                    this.showIndicator()
                    MypageRepositoryImpl().updateEmail(email: this.ui.mailField.text ?? "")
                    this.viewModel?.updateMypage(uid: this.recievedUid, team: this.ui.belongTeamField.text ?? "",
                                                 role: this.ui.positionField.text ?? "",
                                                 mail: this.ui.mailField.text ?? "",
                                                 completion: { _, error in
                        if let error = error {
                            this.hideIndicator(completion: { print(error.localizedDescription) })
                            return
                        }
                        this.hideIndicator(completion: { this.routing.showPrev(vc: this) })
                    })
                })
            }).disposed(by: viewModel.disposeBag)
        
        ui.belongTeamField.rx.controlEvent(.editingDidEndOnExit)
            .bind { [weak self] _ in
                if let _ = self?.ui.belongTeamField.isFirstResponder {
                    self?.ui.positionField.becomeFirstResponder()
                }
            }.disposed(by: viewModel.disposeBag)
        
        ui.positionField.rx.controlEvent(.editingDidEndOnExit)
            .bind { [weak self] _ in
                if let _ = self?.ui.positionField.isFirstResponder {
                    self?.ui.mailField.becomeFirstResponder()
                }
            }.disposed(by: viewModel.disposeBag)
        
        ui.mailField.rx.controlEvent(.editingDidEndOnExit)
            .bind { [weak self] _ in
                if let _ = self?.ui.mailField.isFirstResponder {
                    self?.ui.mailField.resignFirstResponder()
                }
            }.disposed(by: viewModel.disposeBag)
        
        ui.viewTapGesture.rx.event
            .bind{ [weak self] _ in
                self?.view.endEditing(true)
            }.disposed(by: viewModel.disposeBag)
    }
}

extension MypageEditViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return MemberInfoRegisterResources.View.pickerNumberOfComponents
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModel?.outputs.positionArr.count ?? 0
    }
}

extension MypageEditViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return viewModel?.outputs.positionArr[row] ?? R.string.locarizable.empty()
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        ui.positionField.text = viewModel?.outputs.positionArr[row] ?? R.string.locarizable.empty()
    }
}

extension MypageEditViewController: IndicatorShowable {}
