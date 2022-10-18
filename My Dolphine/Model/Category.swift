//
//  Category.swift
//  My Dolphine
//
//  Created by Parth Antala on 2022-10-01.
//

import Foundation

struct Category {
    
    var category: String
    var emoji: String
    var cardNumber: Int
    var counter: Int
    
    init(category: String, emoji: String, cardNumber: Int, counter: Int) {

        self.category = category
        self.emoji = emoji
        self.cardNumber = cardNumber
        self.counter = counter
    }

}
