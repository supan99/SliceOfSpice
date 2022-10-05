//
//  ProfileVC.swift


import UIKit

class ProfileVC: UIViewController {

    
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPhoneNumber: UITextField!
    @IBOutlet weak var txtAddress: UITextField!
    @IBOutlet weak var btnSaveClick: UIButton!
    @IBOutlet weak var btnPaymentInfo: UIButton!
    @IBOutlet weak var btnLogout: UIButton!
    
    
    let user = GFunction.user
    
    @IBAction func btnClick(_ sender: UIButton) {
        if sender == btnPaymentInfo {
            if let vc = UIStoryboard.main.instantiateViewController(withClass: PaymentVC.self) {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }else if sender == btnLogout {
            UIApplication.shared.setStart()
        }else {
            self.updateProfile(docID: user?.docId.description ?? "", name: self.txtName.text ?? "", phoneNumber: self.txtPhoneNumber.text ?? "", address: self.txtAddress.text ?? "")
        }
    }
    
    func setUpData(){
        if self.user != nil {
            self.txtName.text = self.user?.name.description
            self.txtEmail.text = self.user?.email?.description
            self.txtAddress.text = self.user?.address.description
            self.txtPhoneNumber.text = self.user?.phone.description
            self.txtEmail.isUserInteractionEnabled = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpData()
        // Do any additional setup after loading the view.
    }
}


extension ProfileVC {
    func updateProfile(docID: String,name:String,phoneNumber:String, address:String) {
        let ref = AppDelegate.shared.db.collection(sUser).document(docID)
        ref.updateData([
            sName : name,
            sPhone : phoneNumber,
            sAddress : address,
        ]){ err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
                Alert.shared.showAlert(message: "Your Profile has been Updated !!!", completion: nil)
            }
        }
    }
}
