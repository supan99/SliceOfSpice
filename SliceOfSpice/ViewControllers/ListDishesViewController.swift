//
//  ListDishesViewController.swift
//  SliceOfSpice
//


import UIKit


class ListOrdersViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnFilter: UIButton!
    
    var arrayFood = [FoodModel]()
    var categoryData : CategoryModel!
    var isFav: Bool = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getData()
        if categoryData != nil {
            title = "\(categoryData.name) List"
        }
        registerCells()
        self.btnFilter.layer.cornerRadius = 10.0
    }
    
    override func viewDidAppear(_ animated: Bool) {

    }
    
    @IBAction func btnFilterClick(_ sender: UIButton) {
        self.openFilterPicker()
    }

    private func registerCells() {
        tableView.register(UINib(nibName: DishListTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: DishListTableViewCell.identifier)
    }
    
    func openFilterPicker(){
        
        
        let actionSheet = UIAlertController(title: nil, message: "Filter", preferredStyle: .actionSheet)
        
        let ltH = UIAlertAction(title: "Low To High", style: .default, handler: {
            (alert: UIAlertAction) -> Void in
            self.btnFilter.setTitle("Low To High", for: .normal)
            self.arrayFood = self.arrayFood.sorted(by: {Int($0.price) ?? 0 < Int($1.price) ?? 0})
            self.tableView.reloadData()
        })
        
        let htL = UIAlertAction(title: "High To Low", style: .default, handler:
                                            { [self]
            (alert: UIAlertAction) -> Void in
            self.btnFilter.setTitle("High To Low", for: .normal)
            self.arrayFood = self.arrayFood.sorted(by: {Int($0.price) ?? 0 > Int($1.price) ?? 0})
            self.tableView.reloadData()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction) -> Void in
            
        })
       
        actionSheet.addAction(ltH)
        actionSheet.addAction(htL)
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true, completion: nil)
        
    }
}

extension ListOrdersViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayFood.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DishListTableViewCell.identifier) as! DishListTableViewCell
        let data = self.arrayFood[indexPath.row]
        cell.setup(dish: data)
        cell.btnFav.addAction(for: .touchUpInside) {
            self.isFav = false
            if let email = GFunction.user.email {
                self.checkAddToFav(data: data, email: email)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = UIStoryboard.main.instantiateViewController(withClass: DishDetailViewController.self) {
            vc.dish = self.arrayFood[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}



extension ListOrdersViewController {
    func getData(){
        _ = AppDelegate.shared.db.collection(sFood).whereField(sCategoryName, isEqualTo: self.categoryData.name).addSnapshotListener{ querySnapshot, error in
            
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            self.arrayFood.removeAll()
            if snapshot.documents.count != 0 {
                for data in snapshot.documents {
                    let data1 = data.data()
                    if let name: String = data1[sName] as? String, let description: String = data1[sDescription] as? String, let price:String = data1[sPrice] as? String, let categoryName:String = data1[sCategoryName] as? String, let categoryID:String = data1[sCategoryID] as? String, let image:String = data1[sImagePath] as? String {
                        print("Data Count : \(self.arrayFood.count)")
                        self.arrayFood.append(FoodModel(docId: data.documentID, name: name, description: description, price: price,categoryID: categoryID,categoryName: categoryName, imagePath: image))
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
    
    func addToFav(data: FoodModel,email:String){
        var ref : DocumentReference? = nil
        ref = AppDelegate.shared.db.collection(sFavourite).addDocument(data:
            [
                sName: data.name,
                sDescription : data.description,
                sPrice: data.price,
                sEmail: email,
                sFoodID: data.docId
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
