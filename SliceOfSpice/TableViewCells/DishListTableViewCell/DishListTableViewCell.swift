//
//  DishListTableViewCell.swift


import UIKit

class DishListTableViewCell: UITableViewCell {

    static let identifier = "DishListTableViewCell"
    
    @IBOutlet weak var dishImageView: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var btnFav: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.cellView.layer.cornerRadius = 10.0
    }
    
    func setup(dish: FoodModel) {
        dishImageView.setImgWebUrl(url: dish.imagePath, isIndicator: true)
        titleLbl.text = dish.name
        priceLbl.text = "$ \(dish.price)"
    }
    
    func setup(order: FoodModel) {
        dishImageView.setImgWebUrl(url: order.imagePath, isIndicator: true)
        titleLbl.text = order.name
    }
}
