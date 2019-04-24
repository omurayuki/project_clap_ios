import Foundation
import Rswift
import RxCocoa

class SubmittedDetailViewController: UIViewController {
    
    private lazy var ui: SubmittedDetailUI = {
        let ui = SubmittedDetailUIImpl()
        ui.viewController = self
        ui.commentWriteField.delegate = self
        ui.commentTable.register(TimelineCell.self, forCellReuseIdentifier: String(describing: TimelineCell.self))
        ui.commentTable.dataSource = self
        ui.commentTable.delegate = self
        return ui
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ui.setup(vc: self)
    }
}

extension SubmittedDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TimelineCell.self), for: indexPath) as? TimelineCell else { return UITableViewCell() }
        cell.configureInit(image: "hige", title: "hoge", name: "hoge", time: "hogw")
        return cell
    }
}

extension SubmittedDetailViewController: UITableViewDelegate {
    
}

extension SubmittedDetailViewController: UITextFieldDelegate {
    
}