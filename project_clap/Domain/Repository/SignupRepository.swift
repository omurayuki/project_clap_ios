import Foundation
import RxSwift
import Firebase
import FirebaseAuth
import RealmSwift

protocol SignupRepository {
    static func signup(email: String, pass: String, completion: (() -> Void)?)
    static func saveTeamData(teamId: String,
                             team: String,
                             grade: String,
                             sportsKind: String)
    static func whethreRegistUser(teamId: String, uid: String)
    static func saveUserData()
    static func fetchBelongData(teamId: String, completion: @escaping (String) -> Void)
}

struct SignupRepositoryImpl: SignupRepository {
    
    static func signup(email: String, pass: String, completion: (() -> Void)? = nil) {
        Firebase.fireAuth.createUser(withEmail: email, password: pass) { (response, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let response = response else { return }
            let user = User()
            user.uid = response.user.uid
            user.email = response.user.email ?? ""
            user.saveUserData(user: user)
            completion?()
        }
    }
    
    static func saveTeamData(teamId: String,
                             team: String,
                             grade: String,
                             sportsKind: String) {
        let setData = ["belong": team, "grade": grade, "sportsKind": sportsKind]
        Firebase.db
            .collection("team")
            .document(teamId)
            .setData(setData)
    }
    
    static func whethreRegistUser(teamId: String, uid: String) {
        let setData = ["regist": true, "teamId": teamId] as [String : Any]
        Firebase.db
            .collection("team")
            .document(teamId)
            .collection("users")
            .document(uid)
            .setData(setData)
    }
    
    static func saveUserData() {
        //realmに保存したデータを登録
    }
    
    static func fetchBelongData(teamId: String, completion: @escaping (String) -> Void) {
        Firebase.db.collection("team").document(teamId).getDocument(completion: { (response, error) in
            if let response = response, response.exists {
                let description = response.data()
                completion(description?["belong"] as? String ?? "")
            } else {
                print(error as Any)
            }
        })
    }
}