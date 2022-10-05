//
//  AddNewCardVC.swift


import UIKit

class AddNewCardVC: UIViewController {

    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var btnCheck: UIButton!
    @IBOutlet weak var txtCardNumber: UITextField!
    @IBOutlet weak var txtCVV: UITextField!
    @IBOutlet weak var txtCardName: UITextField!
    @IBOutlet weak var txtExpiryDate: UITextField!
    @IBOutlet weak var vwName: UIView!
    @IBOutlet weak var vwCredentials: UIView!
    @IBOutlet weak var imgLogo: UIImageView!

    var data : [FoodModel]!
    
    
    private func setUpView() {
        Alert.shared.showAlert(message: "\(self.data.count)", completion: nil)
        self.applyStyle()
    }
    
    
    private func applyStyle(){
        self.btnAdd.layer.cornerRadius = 7.0
        self.vwName.layer.cornerRadius = 12.0
        self.vwName.layer.borderColor = UIColor.colorLine.cgColor
        self.vwName.layer.borderWidth = 1.0
        self.vwCredentials.layer.cornerRadius = 12.0
        self.vwCredentials.layer.borderColor = UIColor.colorLine.cgColor
        self.vwCredentials.layer.borderWidth = 1.0
        self.txtCVV.textAlignment = .center
        self.txtCVV.delegate = self
        self.txtExpiryDate.delegate = self
        self.txtCardNumber.delegate = self
        self.txtCardName.delegate = self
    }
    
    
    
    
    @IBAction func btnCheckClick(_ sender: UIButton){
        sender.isSelected.toggle()
    }
    
    @IBAction func btnSaveClick(_ sender: Any){
        let error = self.validation()
        if error == "" {
            let total = self.countTotal()
            let date = self.UTCToDate(date: Date())
            if let user = GFunction.user {
                self.addCard(name: self.txtCardName.text ?? "", number: self.txtCardNumber.text ?? "", cvv: self.txtCVV.text ?? "", expDate: self.txtExpiryDate.text ?? "" , email: user.email!)
                self.createOrder(data: self.data, user: user, date: date, total: total)
            }
        }else{
            Alert.shared.showAlert(message: error, completion:  nil)
        }
    }
    
    
    func countTotal() -> String {
        var amount : Float = 0.0
        for cdata in self.data {
            amount += Float(cdata.price) ?? 0.0
        }
        return amount.description
    }
    
    func UTCToDate(date:Date) -> String {
        let formatter = DateFormatter()
        // initially set the format based on your datepicker date / server String
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let myString = formatter.string(from: date) // string purpose I add here
        let yourDate = formatter.date(from: myString)  // convert your string to date
        formatter.dateFormat = "dd, MMM, yyyy"  //then again set the date format whhich type of output you need
        return formatter.string(from: yourDate!) // again convert your date to string
    }
    
    func validation() -> String {
        if self.txtCardNumber.text?.trim() == "" {
            return "Please enter card number"
        }else if self.txtCardNumber.text?.count != 12 {
            return "Please enter valid card number"
        }else if self.txtCardName.text?.trim() == "" {
            return "Please enter card holder name"
        }else if self.txtExpiryDate.text?.trim() == "" {
            return "Please enter expiry date"
        }else if self.txtExpiryDate.text?.count != 7 {
            return "Please enter valid exp date"
        }else if self.txtCVV.text?.trim() == "" {
            return "Please enter cvv"
        }else if self.txtCVV.text?.count != 3 {
            return "Please enter valid cvv"
        }
        return ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.async {
            self.txtCVV.layer.cornerRadius = 7.0
        }
        self.setUpView()
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }

}

extension AddNewCardVC : UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        //TxtMobileNumber allowed only Digits, - and maximum 12 Digits allowed
        if textField == txtCardNumber {
            if ((string.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil) && textField.text!.count < 12) || string.isEmpty{
                return true
            }
        }

        if textField == txtCardName {
            if ((string.rangeOfCharacter(from: CharacterSet.letters) != nil || string.rangeOfCharacter(from: CharacterSet.whitespaces) != nil) || string.isEmpty) {
                return true
            }
        }

        //TxtDate allowed only Digits, / and maximum 6 Digits allowed
        if textField == txtExpiryDate {
            if ((string.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil) && textField.text!.count < 7) || string.isEmpty{
                if (textField.text?.count == 2) && !string.isEmpty {
                    textField.text?.append(" / ")
                }
                return true
            }
//            self.setPicker()
        }

        //TxtCVV allowed only 3 Digits
        if textField == txtCVV {
            textField.textAlignment = .center
            if ((string.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil) && textField.text!.count < 3) || string.isEmpty{
                return true
            }
        }
        return false
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
         if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
         } else {
            textField.resignFirstResponder()
         }
         return false
      }
}


//MARK:- API
extension AddNewCardVC {
    func createOrder(data:[FoodModel], user:UserModel,date:String,total:String){
        var ref : DocumentReference? = nil
        ref = AppDelegate.shared.db.collection(sOrder).addDocument(data:
            [
                sOrderData: data.description,
                sName : user.name.description,
                sEmail: user.email?.description,
                sOrderDate :date,
                sOrderAmount: total
                
            ])
        {  err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
                for data1 in data {
                    self.removeCart(docID: data1.docId)
                }
                Alert.shared.showAlert(message: "Your Order has been placed successfully !!!") { (true) in
                    if let vc = UIStoryboard.main.instantiateViewController(withClass: SuccessMessageVC.self) {
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
        }
    }
    
    func removeCart(docID:String){
        let ref = AppDelegate.shared.db.collection(sCart).document(docID)
        ref.delete(){ err in
            if let err = err {
                print("Error updating document: \(err)")
                self.navigationController?.popViewController(animated: true)
            } else {
                print("Document successfully deleted")
            }
        }
    }
    
    func addCard(name:String,number:String,cvv:String,expDate:String,email:String){
        var ref : DocumentReference? = nil
        ref = AppDelegate.shared.db.collection(sCardList).addDocument(data:
            [
                sCardNumber: number,
                sCardName : name,
                sEmail: email,
                sCardExpiryDate : expDate,
                sCVV: cvv
                
            ])
        {  err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
    }
}
