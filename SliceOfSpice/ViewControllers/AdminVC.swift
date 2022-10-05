//
//  AdminVC.swift


import UIKit



class AdminVC: UIViewController {

    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var specialsCollectionView: UICollectionView!
    
    @IBOutlet weak var btnAddCategory: UIButton!
    @IBOutlet weak var btnAddFood: UIButton!
    
    
    var array = [CategoryModel]()
    var arrayFood = [FoodModel]()
    
    @IBAction func btnAddClick(_ sender: UIButton) {
        if sender == btnAddFood {
            if let vc = UIStoryboard.main.instantiateViewController(withClass: AddFoodVC.self) {
                self.navigationController?.pushViewController(vc, animated:     true)
            }
        }else{
            if let vc = UIStoryboard.main.instantiateViewController(withClass: AddCategoryVC.self) {
                self.navigationController?.pushViewController(vc, animated:     true)
            }
        }
    }
    
    @IBAction func btnLogout(_ sender: Any) {
        UIApplication.shared.setStart()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        specialsCollectionView.dataSource = self
        specialsCollectionView.delegate = self
        
        tableView.dataSource = self
        tableView.delegate = self
        
        self.btnAddFood.layer.cornerRadius = 12.0
        self.btnAddCategory.layer.cornerRadius = 12.0
        registerCells()
        
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        navigationController?.navigationBar.tintColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getData()
        self.getFoodData()
    }
    
    private func registerCells() {
        categoryCollectionView.register(UINib(nibName: CategoryCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: CategoryCollectionViewCell.identifier)
        tableView.register(UINib(nibName: DishListTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: DishListTableViewCell.identifier)
        specialsCollectionView.register(UINib(nibName: DIshLandscapeCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: DIshLandscapeCollectionViewCell.identifier)
    }
    
}

extension AdminVC: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case categoryCollectionView:
            return self.array.count
        case specialsCollectionView:
            return self.arrayFood.count
        default: return self.array.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch collectionView {
        case categoryCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.identifier, for: indexPath) as! CategoryCollectionViewCell
            cell.setup(category: self.array[indexPath.row])
            return cell
        case specialsCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DIshLandscapeCollectionViewCell.identifier, for: indexPath) as! DIshLandscapeCollectionViewCell
            cell.setup(dish: arrayFood[indexPath.row])
            return cell
        default: return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        if collectionView == categoryCollectionView {
//            if let vc = UIStoryboard.main.instantiateViewController(withClass: ListOrdersViewController.self) {
//                self.navigationController?.pushViewController(vc, animated: true)
//            }
//        } else {
//            if let vc = UIStoryboard.main.instantiateViewController(withClass: DishDetailViewController.self) {
//                self.navigationController?.pushViewController(vc, animated: true)
//            }
//        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
    }
}


extension AdminVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayFood.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DishListTableViewCell.identifier) as! DishListTableViewCell
        cell.setup(dish: arrayFood[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if let vc = UIStoryboard.main.instantiateViewController(withClass: DishDetailViewController.self) {
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
//        let controller = DishDetailViewController.instantiate()
//        controller.dish = orders[indexPath.row].dish
//        navigationController?.pushViewController(controller, animated: true)
    }
}


extension AdminVC {
    func getData() {
        _ = AppDelegate.shared.db.collection(sCategory).addSnapshotListener{ querySnapshot, error in
            
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            self.array.removeAll()
            if snapshot.documents.count != 0 {
                for data in snapshot.documents {
                    let data1 = data.data()
                    if let name: String = data1[sName] as? String, let description: String = data1[sDescription] as? String,let imagePath: String = data1[sImagePath] as? String {
                        print("Data Count : \(self.array.count)")
                        self.array.append(CategoryModel(docId: data.documentID, name: name, description: description, imagePath: imagePath))
                    }
                }
                self.categoryCollectionView.delegate = self
                self.categoryCollectionView.dataSource = self
                self.categoryCollectionView.reloadData()
            }else{
                Alert.shared.showAlert(message: "No Data Found !!!", completion: nil)
            }
        }
    }
    
    func getFoodData() {
        _ = AppDelegate.shared.db.collection(sFood).addSnapshotListener{ querySnapshot, error in
            
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
}
