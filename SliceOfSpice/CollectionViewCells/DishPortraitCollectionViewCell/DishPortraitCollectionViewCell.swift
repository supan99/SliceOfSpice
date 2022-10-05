//
//  DishPortraitCollectionViewCell.swift
import UIKit

class DishPortraitCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "DishPortraitCollectionViewCell"

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var dishImageView: UIImageView!
    @IBOutlet weak var caloriesLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var vwCell: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.vwCell.layer.cornerRadius = 5.0
        self.vwCell.clipsToBounds = true
    }
    
    func setup(dish: FoodModel) {
        titleLbl.text = dish.name
        dishImageView.setImgWebUrl(url: dish.imagePath, isIndicator: true)
        caloriesLbl.text = "$ \(dish.price)"
        descriptionLbl.text = dish.description
    }
}
