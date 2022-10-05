//
//  HomeVC.swift

import UIKit

class HomeVC: UIViewController {

    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var popularCollectionView: UICollectionView!
    
    var array = [CategoryModel]()
    var arrayFood = [FoodModel]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.categoryCollectionView.delegate = self
        self.categoryCollectionView.dataSource = self
        
        self.getData()
        self.getFoodData()
        registerCells()
        
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        navigationController?.navigationBar.tintColor = .white
    }
    
    private func registerCells() {
        categoryCollectionView.register(UINib(nibName: CategoryCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: CategoryCollectionViewCell.identifier)
        popularCollectionView.register(UINib(nibName: DishPortraitCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: DishPortraitCollectionViewCell.identifier)
    }
    
}

extension HomeVC: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case categoryCollectionView:
            return self.array.count
        case popularCollectionView:
            return self.arrayFood.count
        default: return self.array.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch collectionView {
        case categoryCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.identifier, for: indexPath) as! CategoryCollectionViewCell
            cell.setup(category: array[indexPath.row])
            return cell
        case popularCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DishPortraitCollectionViewCell.identifier, for: indexPath) as! DishPortraitCollectionViewCell
           cell.setup(dish: arrayFood[indexPath.row])
            return cell
        default: return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == categoryCollectionView {
            if let vc = UIStoryboard.main.instantiateViewController(withClass: ListOrdersViewController.self) {
                vc.categoryData = self.array[indexPath.row]
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            if let vc = UIStoryboard.main.instantiateViewController(withClass: DishDetailViewController.self) {
                vc.dish = self.arrayFood[indexPath.row]
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.popularCollectionView {
            return CGSize(width: self.popularCollectionView.frame.width/2, height: 250)
        }else if collectionView == self.categoryCollectionView {
            return CGSize(width: self.categoryCollectionView.frame.size.width, height: self.categoryCollectionView.frame.size.height)
        }
        return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
    }
}


extension HomeVC {
    
    func getData(){
        _ = AppDelegate.shared.db.collection(sCategory).addSnapshotListener{ querySnapshot, error in
            
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            self.array.removeAll()
            if snapshot.documents.count != 0 {
                for data in snapshot.documents {
                    let data1 = data.data()
                    if let name: String = data1[sName] as? String, let description: String = data1[sDescription] as? String, let imagePath: String = data1[sImagePath] as? String {
                        self.array.append(CategoryModel(docId: data.documentID, name: name, description: description, imagePath: imagePath))
                    }
                }
                print("Category Data Count : \(self.array.count)")
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
                self.popularCollectionView.delegate = self
                self.popularCollectionView.dataSource = self
                self.popularCollectionView.reloadData()
            }else{
                Alert.shared.showAlert(message: "No Data Found !!!", completion: nil)
            }
        }
    }
}
