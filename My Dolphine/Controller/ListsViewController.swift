//
//  ListsViewController.swift
//  My Dolphine
//
//  Created by Parth Antala on 2022-09-30.
//

import UIKit

class ListsViewController: UIViewController {

    let addButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addButton.setTitle("", for: .normal)
        addButton.setImage(UIImage(named: "addToDo"), for: .normal)
        self.view.addSubview(addButton)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.topAnchor.constraint(greaterThanOrEqualToSystemSpacingBelow: view.topAnchor, multiplier: 80).isActive = true
        addButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10).isActive = true
        addButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -50).isActive = true
        addButton.addTarget(self, action: #selector(toAddToDo), for: .touchUpInside)
    }
    

    @objc func toAddToDo(){
        performSegue(withIdentifier: "toAddToDo", sender: self)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
