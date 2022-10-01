//
//  Category.swift
//  My Dolphine
//
//  Created by Parth Antala on 2022-10-01.
//

import Foundation
import Firebase

struct Category {
    
    let ref: DatabaseReference?
    let key: String
    var category: String
    var emoji: String
    var cardNumber: Int
    var counter: Int
    
    init(category: String, emoji: String, cardNumber: Int, counter: Int, key:String = "") {
        
        self.ref = nil
        self.key = key
        self.category = category
        self.emoji = emoji
        self.cardNumber = cardNumber
        self.counter = counter
        
    }
    
    init?(snapshot: DataSnapshot) {
        //MARK: - Database is taking a snapshot of the grocery item once it has been initialized, sends item to Firebase database
        
        guard
            let value = snapshot.value as? [String: AnyObject],
            let category = value["category"] as? String,
            let emoji = value["emoji"] as? String,
            let cardNumber = value["cardNumber"] as? Int,
            let counter = value["counter"] as? Int
        else {
            return nil
        }
           
        //MARK: - Read items from online and set them within our app as grocery items
        self.ref = snapshot.ref
        self.key = snapshot.key
        self.category = category
        self.emoji = emoji
        self.cardNumber = cardNumber
        self.counter = counter
    
    }
    
    func toAnyObject() -> Any {
        return [
            "category": category,
            "emoji": emoji,
            "cardNumber": cardNumber,
            "counter": counter
        ]
    }
}
