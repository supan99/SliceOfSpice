//
//  CategoryModel.swift
//  SliceOfSpice
//
//  Created by 2022M3 on 05/05/22.
//

import Foundation
class CategoryModel {
    
    var name:String
    var description: String
    var docId: String
    var imagePath:String
    
    init(docId:String, name:String, description:String, imagePath:String) {
        self.docId = docId
        self.name = name
        self.description = description
        self.imagePath = imagePath
    }

}
