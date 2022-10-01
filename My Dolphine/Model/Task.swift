//
//  Task.swift
//  My Dolphine
//
//  Created by Parth Antala on 2022-09-30.
//

import Foundation
import Firebase

struct Task{
    
    let ref: DatabaseReference?
    let key: String
    var name: String = ""
    var quantity: Int = 0
    var comment: String = ""
    var category: String = ""
    init(name: String, quantity: Int, comment: String, category: String, key: String = ""){
        self.ref = nil
        self.key = key
        self.name = name
        self.quantity = quantity
        self.comment = comment
        self.category = category
    }
    
    init?(snapshot: DataSnapshot) {
        //MARK: - Database is taking a snapshot of the grocery item once it has been initialized, sends item to Firebase database
        
        guard
            let value = snapshot.value as? [String: AnyObject],
            let name = value["name"] as? String,
            let quantity = value["quantity"] as? Int,
            let comment = value["comment"] as? String,
            let category = value["category"] as? String
        else {
            return nil
        }
           
        //MARK: - Read items from online and set them within our app as grocery items
        self.ref = snapshot.ref
        self.key = snapshot.key
        self.name = name
        self.comment = comment
        self.quantity = quantity
        self.category = category
    }
    
    func toAnyObject() -> Any {
        return [
            "name": name,
            "comment": comment,
            "quantity": quantity,
            "category": category
        ]
    }
}
