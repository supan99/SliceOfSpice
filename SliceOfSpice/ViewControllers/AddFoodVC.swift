//
//  AddFoodVC.swift


import UIKit

class AddFoodVC: UIViewController, UINavigationControllerDelegate {

    @IBOutlet weak var txtname: UITextField!
    @IBOutlet weak var txtPrice: UITextField!
    @IBOutlet weak var txtCategory: UITextField!
    @IBOutlet weak var txtDescription: UITextField!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var btnAdd: BlueThemeButton!
    
    var picker = UIPickerView()
    var array = [CategoryModel]()
    var data : CategoryModel!
    var storageRef = StorageReference()
    var imgPicker = UIImagePickerController()
    var imageData = UIImage()
    var imgPicker1 = OpalImagePickerController()
    var isImageSelected = false
    var imageURL = ""
    
    @IBAction func btnAddClick(_ sender: UIButton) {
        let error = self.validation()
        if error == "" {
            self.addFood(name: self.txtname.text ?? "", description: self.txtDescription.text ?? "", price: self.txtPrice.text ?? "",data: self.data)
        }else{
            Alert.shared.showAlert(message: error, completion: nil)
        }
        
    }
    
    func validation() -> String {
        if !isImageSelected {
         return "Please select Image"
        }else if self.txtname.text?.trim() == ""{
            return "Please enter name"
        }else if self.txtPrice.text?.trim() == "" {
            return "Please enter price"
        }else if self.txtDescription.text?.trim() == "" {
            return "Please enter description"
        }
        return ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getData()
        self.txtCategory.inputView = picker
        let tap = UITapGestureRecognizer()
        tap.addAction {
            self.openPicker()
        }
        self.imgView.isUserInteractionEnabled = true
        self.imgView.addGestureRecognizer(tap)
        self.imgView.layer.cornerRadius = self.imgView.frame.height/2
        self.imgView.layer.borderColor = UIColor.red.cgColor
        self.imgView.layer.borderWidth = 1.0
        // Do any additional setup after loading the view.
    }
    
    func openPicker(){
        
        
        let actionSheet = UIAlertController(title: nil, message: "Select Image", preferredStyle: .actionSheet)
        
        let cameraPhoto = UIAlertAction(title: "Camera", style: .default, handler: {
            (alert: UIAlertAction) -> Void in
            guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
                return Alert.shared.showAlert(message: "Camera not Found", completion: nil)
            }
            GFunction.shared.isGiveCameraPermissionAlert(self) { (isGiven) in
                if isGiven {
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        self.imgPicker.mediaTypes = ["public.image"]
                        self.imgPicker.sourceType = .camera
                        self.imgPicker.cameraDevice = .rear
                        self.imgPicker.allowsEditing = true
                        self.imgPicker.delegate = self
                        self.present(self.imgPicker, animated: true)
                    }
                }
            }
        })
        
        let PhotoLibrary = UIAlertAction(title: "Gallary", style: .default, handler:
                                            { [self]
            (alert: UIAlertAction) -> Void in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
                let photos = PHPhotoLibrary.authorizationStatus()
                if photos == .denied || photos == .notDetermined {
                    PHPhotoLibrary.requestAuthorization({status in
                        if status == .authorized {
                            DispatchQueue.main.async {
                                self.imgPicker1 = OpalImagePickerController()
                                self.imgPicker1.imagePickerDelegate = self
                                self.imgPicker1.isEditing = true
                                present(self.imgPicker1, animated: true, completion: nil)
                            }
                        }
                    })
                }else if photos == .authorized {
                    DispatchQueue.main.async {
                        self.imgPicker1 = OpalImagePickerController()
                        self.imgPicker1.imagePickerDelegate = self
                        self.imgPicker1.isEditing = true
                        present(self.imgPicker1, animated: true, completion: nil)
                    }
                    
                }
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction) -> Void in
            
        })
        
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        actionSheet.addAction(cameraPhoto)
        actionSheet.addAction(PhotoLibrary)
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true, completion: nil)
        
    }

}

extension AddFoodVC {
    func addFood(name: String, description:String,price: String,data: CategoryModel) {
        var ref : DocumentReference? = nil
        ref = AppDelegate.shared.db.collection(sFood).addDocument(data:
            [
              sName: name,
              sDescription : description,
              sPrice: price,
              sCategoryID: data.docId,
              sCategoryName: data.name,
              sImagePath : self.imageURL
            ])
        {  err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
                Alert.shared.showAlert(message: "Your food has been added Successfully !!!") { (true) in
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
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
                    if let name: String = data1[sName] as? String, let description: String = data1[sDescription] as? String, let imagePath: String = data1[sImagePath] as? String {
                        print("Data Count : \(self.array.count)")
                        self.array.append(CategoryModel(docId: data.documentID, name: name, description: description, imagePath: imagePath))
                    }
                }
                self.data = self.array[0]
                self.picker.delegate = self
                self.picker.dataSource = self
                self.picker.reloadAllComponents()
            } else {
                Alert.shared.showAlert(message: "No Data Found !!!", completion: nil)
            }
        }
    }
}


extension AddFoodVC: UIPickerViewDelegate,UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.array.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.array[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.data = self.array[row]
        self.txtCategory.text = self.array[row].name
//        self.data = self.array[row]
    }
}


//MARK:- UIImagePickerController Delegate Methods
extension AddFoodVC: UIImagePickerControllerDelegate, OpalImagePickerControllerDelegate {
    func uploadImagePic(img1 :UIImage){
        let data = img1.jpegData(compressionQuality: 0.8)! as NSData
        // set upload path
        let imagePath = GFunction.shared.UTCToDate(date: Date())
        let filePath = "Food/\(imagePath)" // path where you wanted to store img in storage
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
        let storageRef = Storage.storage().reference(withPath: filePath)
        storageRef.putData(data as Data, metadata: metaData) { (metaData, error) in
            if let error = error {
                return
            }
            storageRef.downloadURL(completion: { (url: URL?, error: Error?) in
                self.isImageSelected = true
                self.imageURL = url?.absoluteString ?? ""
                print(url?.absoluteString) // <- Download URL
                self.imgView.setImgWebUrl(url: self.imageURL, isIndicator: true)
            })
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        defer {
            picker.dismiss(animated: true)
        }
        if let image = info[.editedImage] as? UIImage {
            uploadImagePic(img1: image)
        }

    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        do { picker.dismiss(animated: true) }
    }
    
    func imagePicker(_ picker: OpalImagePickerController, didFinishPickingAssets assets: [PHAsset]){
        for image in assets {
            if let image = getAssetThumbnail(asset: image) as? UIImage {
                uploadImagePic(img1: image)
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    func getAssetThumbnail(asset: PHAsset) -> UIImage {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var thumbnail = UIImage()
        option.isSynchronous = true
        manager.requestImage(for: asset, targetSize: CGSize(width: (asset.pixelWidth), height: ( asset.pixelHeight)), contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
            thumbnail = result!
        })
        return thumbnail
    }
    
    func imagePickerDidCancel(_ picker: OpalImagePickerController){
        dismiss(animated: true, completion: nil)
    }
}
