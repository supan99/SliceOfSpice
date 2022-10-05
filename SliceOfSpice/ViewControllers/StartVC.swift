//
//  StartVC.swift


import UIKit

class StartVC: UIViewController {

    @IBOutlet weak var btnEmail: UIButton!
    @IBOutlet weak var btnGoogle: UIButton!
    @IBOutlet weak var btnFacebook: UIButton!
    @IBOutlet weak var lblLogin: UILabel!
    
    private let socialLoginManager: SocialLoginManager = SocialLoginManager()
    
    
    
    func applyStyle(){
        self.lblLogin.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer()
        tap.addAction {
            if let vc = UIStoryboard.main.instantiateViewController(withClass: LoginVC.self) {
            self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        self.lblLogin.addGestureRecognizer(tap)
        
        self.btnEmail.layer.cornerRadius = 16.0
        self.btnGoogle.layer.cornerRadius = 16.0
        self.btnFacebook.layer.cornerRadius = 16.0
        self.socialLoginManager.delegate = self
    }
    
    @IBAction func btnSignUpWithEmailTapped(_ sender: UIButton) {
        if sender == btnEmail {
            if let vc = UIStoryboard.main.instantiateViewController(withClass: SignUpVC.self) {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }else if sender == btnGoogle {
            self.socialLoginManager.performGoogleLogin(vc: self)
        }else if sender == btnFacebook {
            self.socialLoginManager.performAppleLogin()
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.applyStyle()
        // Do any additional setup after loading the view.
    }

}

extension StartVC: SocialLoginDelegate {

    func socialLoginData(data: SocialLoginDataModel) {
        print("Social Id==>", data.socialId ?? "")
        print("First Name==>", data.firstName ?? "")
        print("Last Name==>", data.lastName ?? "")
        print("Email==>", data.email ?? "")
        print("Login type==>", data.loginType ?? "")
        self.loginUser(email: data.email, password: data.socialId,data: data)
    }

    func loginUser(email:String,password:String,data: SocialLoginDataModel) {
        
        _ = AppDelegate.shared.db.collection(sUser).whereField(sEmail, isEqualTo: email).addSnapshotListener{ querySnapshot, error in
            
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            if snapshot.documents.count != 0 {
                if let vc = UIStoryboard.main.instantiateViewController(withClass:  LoginVC.self) {
                    vc.socialData = data
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }else{
                if let vc = UIStoryboard.main.instantiateViewController(withClass:  SignUpVC.self) {
                    vc.socialData = data
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
}
