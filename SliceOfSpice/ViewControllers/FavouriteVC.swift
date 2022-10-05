//
//  FavouriteVC.swift


import UIKit

class FavouriteVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var array = [FoodModel]()
    var isFav : Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Cart List"
    }
    
    
    @IBAction func btnPaymentClick(_ sender: UIButton) {
        if let vc = UIStoryboard.main.instantiateViewController(withClass: AddNewCardVC.self){
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerCells()
        if let email = GFunction.user.email {
            self.getFavData(email: email)
        }
    }

    private func registerCells() {
        tableView.register(UINib(nibName: DishListTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: DishListTableViewCell.identifier)
    }
}

extension FavouriteVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DishListTableViewCell.identifier) as! DishListTableViewCell
        let data = self.array[indexPath.row]
        cell.setup(dish: data)
        cell.btnFav.isSelected = true
        cell.btnFav.addAction(for: .touchUpInside) {
            self.isFav = false
            if let email = GFunction.user.email {
                self.removeFromFav(data: data, email: email)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        Alert.shared.showAlert(message: "Food has been removed from favourite list") { (true) in
//            self.tableView.reloadData()
//        }
    }
}


//MARK:- API
extension  FavouriteVC {
    func getFavData(email:String){
        _ = AppDelegate.shared.db.collection(sFavourite).whereField(sEmail, isEqualTo: email).addSnapshotListener{ querySnapshot, error in
            
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            self.array.removeAll()
            if snapshot.documents.count != 0 {
                for data in snapshot.documents {
                    let data1 = data.data()
                    if let name: String = data1[sName] as? String, let description: String = data1[sDescription] as? String, let price:String = data1[sPrice] as? String,let categoryID:String = data1[sFoodID] as? String, let image:String = data1[sImagePath] as? String  {
                        print("Favourite Data Count : \(self.array.count)")
                        self.array.append(FoodModel(docId: data.documentID, name: name, description: description, price: price,categoryID: categoryID,categoryName: "", imagePath: image))
                    }
                }
                self.tableView.delegate = self
                self.tableView.dataSource = self
                self.tableView.reloadData()
            }else{
                Alert.shared.showAlert(message: "No Data Found !!!", completion: nil)
            }
        }
    }
    
    func removeFromFav(data: FoodModel,email:String){
        let ref = AppDelegate.shared.db.collection(sFavourite).document(data.docId)
        ref.delete(){ err in
            if let err = err {
                print("Error updating document: \(err)")
                self.navigationController?.popViewController(animated: true)
            } else {
                print("Document successfully deleted")
                UIApplication.shared.setTab()
            }
        }
    }
}
