//
//  SelectCatViewController.swift
//  My Dolphine
//
//  Created by Parth Antala on 2022-10-06.
//

import UIKit
import CoreData

protocol selectedCat {
    func setCategory(category: String)
}
class SelectCatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var delegate: selectedCat?
    var categories: [Categories] = []
    
    @IBOutlet weak var tableView: UITableView!
   
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.systemGray6
    }
    
    //MARK: - viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        let theme = UserDefaults.standard.integer(forKey: "theme")
        
        if theme == 1 {
            view.backgroundColor = .black
        } else {
            view.backgroundColor = .systemGray6
        }
    }
    
    //MARK: - tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "catCell", for: indexPath)
        
        cell.textLabel?.text = categories[indexPath.row].name
        print(categories[indexPath.row].name)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.setCategory(category: categories[indexPath.row].name!)
        self.dismiss(animated: true)
    }
}
