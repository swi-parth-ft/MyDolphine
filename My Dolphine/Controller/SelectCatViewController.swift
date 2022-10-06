//
//  SelectCatViewController.swift
//  My Dolphine
//
//  Created by Parth Antala on 2022-10-06.
//

import UIKit
protocol selectedCat {
    func setCategory(category: String)
}
class SelectCatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var delegate: selectedCat?
    @IBOutlet weak var tableView: UITableView!
    var categories: [Category] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.systemGray6
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "catCell", for: indexPath)
        
        cell.textLabel?.text = categories[indexPath.row].category
        print(categories[indexPath.row].category)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.setCategory(category: categories[indexPath.row].category)
        self.dismiss(animated: true)
    }

    
   

}
