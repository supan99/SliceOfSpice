//
//  CategoryCollectionViewCell.swift

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
    
    static let identifier = String(describing: CategoryCollectionViewCell.self)

    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var categoryTitleLbl: UILabel!
    @IBOutlet weak var categoryView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.categoryView.layer.cornerRadius = 10.0
    }
    
    func setup(category: CategoryModel) {
        categoryTitleLbl.text = category.name
        categoryImageView.setImgWebUrl(url: category.imagePath, isIndicator: true)
    }
}
