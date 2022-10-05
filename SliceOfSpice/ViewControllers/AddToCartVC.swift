//
//  AddToCartVC.swift


import UIKit

class AddToCartVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnProceedToPay: UIButton!
    @IBOutlet weak var btnTakeOut: UIButton!
    
    var array = [FoodModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Cart List"
        registerCells()
        self.btnTakeOut.layer.cornerRadius = 5.0
    }
    
    
    @IBAction func btnPaymentClick(_ sender: UIButton) {
        if let vc = UIStoryboard.main.instantiateViewController(withClass: AddNewCardVC.self){
            vc.data = self.array
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func btnTakeOutClick(_ sender: UIButton) {
        self.openDinePicker()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let email = GFunction.user.email {
            self.getCartData(email: email)
        }
    }
    
    func openDinePicker(){
        
        
        let actionSheet = UIAlertController(title: nil, message: "Select Delivery type", preferredStyle: .actionSheet)
        
        let dineOut = UIAlertAction(title: "Dine Out", style: .default, handler: {
            (alert: UIAlertAction) -> Void in
            self.btnTakeOut.setTitle("Dine Out", for: .normal)
        })
        
        let takeAway = UIAlertAction(title: "Take Away", style: .default, handler:
                                            { [self]
            (alert: UIAlertAction) -> Void in
            self.btnTakeOut.setTitle("Take Away", for: .normal)
        })
        
        let homeDelivery = UIAlertAction(title: "Home Delivery", style: .default, handler:
                                            { [self]
            (alert: UIAlertAction) -> Void in
            self.btnTakeOut.setTitle("Home Delivery", for: .normal)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction) -> Void in
            
        })
       
        actionSheet.addAction(dineOut)
        actionSheet.addAction(takeAway)
        actionSheet.addAction(homeDelivery)
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true, completion: nil)
        
    }
    
    private func registerCells() {
        tableView.register(UINib(nibName: DishListTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: DishListTableViewCell.identifier)
    }
}

extension AddToCartVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.btnProceedToPay.isEnabled = true
        self.btnProceedToPay.isUserInteractionEnabled = true
        if self.array.count == 0 {
            self.btnProceedToPay.isEnabled = false
            self.btnProceedToPay.isUserInteractionEnabled = false
        }
        return self.array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DishListTableViewCell.identifier) as! DishListTableViewCell
        let data = self.array[indexPath.row]
        cell.setup(order: data)
        cell.btnFav.isHighlighted = true
        cell.btnFav.addAction(for: .touchUpInside) {
            self.removeItem(docID: data.docId)
        }
        cell.btnFav.isHidden = true
        return cell
    }
}

//MARK:- API
extension AddToCartVC {
    func getCartData(email:String){
        _ = AppDelegate.shared.db.collection(sCart).addSnapshotListener{ querySnapshot, error in
            
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            self.array.removeAll()
            if snapshot.documents.count != 0 {
                for data in snapshot.documents {
                    let data1 = data.data()
                    if let name: String = data1[sName] as? String, let description: String = data1[sDescription] as? String, let price:String = data1[sPrice] as? String,let categoryID:String = data1[sFoodID] as? String, let imagePath:String = data1[sImagePath] as? String {
                        print("cart Data Count : \(self.array.count)")
                        self.array.append(FoodModel(docId: data.documentID, name: name, description: description, price: price,categoryID: categoryID,categoryName: "",imagePath: imagePath))
                    }
                }
                self.tableView.delegate = self
                self.tableView.dataSource = self
                self.tableView.reloadData()
            }else{
                self.tableView.reloadData()
                Alert.shared.showAlert(message: "No Data Found !!!", completion: nil)
            }
        }
    }
    
    func removeItem(docID:String){
        let ref = AppDelegate.shared.db.collection(sCart).document(docID)
        ref.delete(){ err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                if let email = GFunction.user.email {
                    self.getCartData(email: email)
                }
                print("Document successfully deleted")
            }
        }
    }
}
