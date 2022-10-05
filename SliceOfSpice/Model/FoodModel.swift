//
//  FoodModel.swift
//  SliceOfSpice
//
//  Created by 2022M3 on 05/05/22.
//

import Foundation
class FoodModel {
    
    var name:String
    var description: String
    var docId: String
    var price: String
    var categoryName: String
    var categoryID: String
    var imagePath: String
    
    init(docId:String, name:String, description:String,price:String,categoryID:String,categoryName:String, imagePath: String) {
        self.docId = docId
        self.name = name
        self.description = description
        self.price = price
        self.categoryName = categoryName
        self.categoryID = categoryID
        self.imagePath = imagePath
    }

}
