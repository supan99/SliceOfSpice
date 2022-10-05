//
//  CardModel.swift

import Foundation

class CardModel {
    
    var name:String
    var cardNumber: String
    var expiryDate: String
    var cvv: String
    var docId: String
    var email: String
    
    init(docId:String, name:String, cardNumber:String,expiryDate:String,cvv:String,email:String) {
        self.docId = docId
        self.name = name
        self.cardNumber = cardNumber
        self.expiryDate = expiryDate
        self.cvv = cvv
        self.email = email
    }
}
