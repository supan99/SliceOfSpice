//
//  DishDetailViewController.swift


import UIKit

class DishDetailViewController: UIViewController {

    @IBOutlet weak var dishImageView: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var caloriesLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var btnAddToCart: UIButton!
    @IBOutlet weak var btnAddToFav: UIButton!
    
    var dish: FoodModel!
    var isCart : Bool = true
    var isFav : Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        populateView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        dishImageView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner,]
        dishImageView.layer.cornerRadius = 45
        dishImageView.layer.borderColor = UIColor.white.cgColor
        dishImageView.layer.borderWidth = 5.0
    }
    
    private func populateView() {
        titleLbl.text = dish.name
        descriptionLbl.text = dish.description
        caloriesLbl.text = "$ \(dish.price)"
        dishImageView.setImgWebUrl(url: dish.imagePath, isIndicator: true)
    }
    
    @IBAction func placeOrderBtnClicked(_ sender: UIButton) {
        if sender == btnAddToFav {
            self.isFav = false
            if let email = GFunction.user.email {
                self.checkAddToFav(data: self.dish, email: email)
            }
        }else if sender == btnAddToCart {
            self.isCart = false
            if let email = GFunction.user.email {
                self.checkCart(data: self.dish, email: email)
            }
        }
    }
}


//MARK:- APIs
extension DishDetailViewController {
    func addToCart(data:FoodModel, email:String){
        var ref : DocumentReference? = nil
        ref = AppDelegate.shared.db.collection(sCart).addDocument(data:
            [
                sName: data.name,
                sDescription : data.description,
                sPrice: data.price,
                sEmail: email,
                sFoodID: data.docId,
                sImagePath: data.imagePath
            ])
        {  err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
                Alert.shared.showAlert(message: "Item has been added into cart!!!") { (true) in
                    UIApplication.shared.setTab()
                }
            }
        }
    }
    
    func checkCart(data: FoodModel,email:String){
        _ = AppDelegate.shared.db.collection(sCart).whereField(sEmail, isEqualTo: email).whereField(sFoodID, isEqualTo: data.docId).addSnapshotListener{ querySnapshot, error in
            
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            if snapshot.documents.count == 0 {
                self.isCart = true
                self.addToCart(data: data, email: email)
            }else{
                if !self.isCart{
                    Alert.shared.showAlert(message: "Item has been already existing into Cart!!!", completion: nil)
                    
                }
            }
        }
    }
    
    func addToFav(data: FoodModel,email:String){
        var ref : DocumentReference? = nil
        ref = AppDelegate.shared.db.collection(sFavourite).addDocument(data:
            [
                sName: data.name,
                sDescription : data.description,
                sPrice: data.price,
                sEmail: email,
                sFoodID: data.docId,
                sImagePath: data.imagePath
            ])
        {  err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
                Alert.shared.showAlert(message: "Item has been added into Favourite!!!") { (true) in
                    UIApplication.shared.setTab()
                }
            }
        }
    }
    
    func checkAddToFav(data: FoodModel, email:String) {
        _ = AppDelegate.shared.db.collection(sFavourite).whereField(sEmail, isEqualTo: email).whereField(sFoodID, isEqualTo: data.docId).addSnapshotListener{ querySnapshot, error in
            
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            if snapshot.documents.count == 0 {
                self.isFav = true
                self.addToFav(data: data, email: email)
            }else{
                if !self.isFav {
                    Alert.shared.showAlert(message: "Item has been already existing into Favourite!!!", completion: nil)
                }
                
            }
        }
    }
}
