//
//  Task.swift
//  My Dolphine
//
//  Created by Parth Antala on 2022-09-30.
//

import Foundation

struct Task{
    

    var name: String
    var quantity: Int
    var comment: String
    var category: String
    var done: Bool
    
    init(name: String, quantity: Int, comment: String, category: String, done: Bool){

        self.name = name
        self.quantity = quantity
        self.comment = comment
        self.category = category
        self.done = done
    }
    

}
