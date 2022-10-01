//
//  ListsViewController.swift
//  My Dolphine
//
//  Created by Parth Antala on 2022-09-30.
//

import UIKit
import Firebase

class ListsViewController: UIViewController, selectedCategories {
    
    var tempCategories:[String] = []
    var tempCategories1:[String] = []
    var cardCounter = 1
    var selectedCategory: String = ""
    
    
    func setCategory(category: String) {
        print(category)
        selectedCategory = category
    }
    
    
    
    @IBOutlet weak var CategoriesCollection: UICollectionView!
    var imageArray = [UIImage(named: "workToDoImage"),UIImage(named: "workToDoImage"),UIImage(named: "workToDoImage")]
    let addButton = UIButton()
    
    var categories: [Category] = []
    var items: [Task] = []
    
    let ref = Database.database().reference(withPath: "items")
    let ref1 = Database.database().reference(withPath: "categories")
    
    var refObservers: [DatabaseHandle] = []
    var handle: AuthStateDidChangeListenerHandle?
    
    @IBOutlet weak var tableview: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(selectedCategory)
        
        addButton.setTitle("", for: .normal)
        addButton.setImage(UIImage(named: "addToDo"), for: .normal)
        self.view.addSubview(addButton)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.topAnchor.constraint(greaterThanOrEqualToSystemSpacingBelow: view.topAnchor, multiplier: 80).isActive = true
        addButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10).isActive = true
        addButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -50).isActive = true
        addButton.addTarget(self, action: #selector(toAddToDo), for: .touchUpInside)
        
        tableview.delegate = self
        tableview.dataSource = self
        tableview.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "ReusableCell")
        
        CategoriesCollection.delegate = self
        CategoriesCollection.dataSource = self
        
        
            
       
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        ref.observe(.value, with: { snapshot in
            print("-------------")
            print(self.selectedCategory)
            print(snapshot.value as Any)
            print("-------------")
        })

        //MARK: - Download grocery items from database
        ref.queryOrdered(byChild: "completed").observe(.value, with: { snapshot in
            //MARK: - Populate a list of grocery items to download
            var newItems: [Task] = []
            for child in snapshot.children {
                //MARK: - Create snapshot which will be a child of all of our snapshots
                if let snapshot = child as? DataSnapshot,
                   //MARK: - Create grocery item from downloaded snapshot, add to list
                   let groceryItem = Task(snapshot: snapshot) {
                    newItems.append(groceryItem)
                }
            }
            //MARK: - Set items in table to newItems
            self.items = newItems
            self.tableview.reloadData()
            for item in self.items {
                self.tempCategories.append(item.category)
                print("----------------------item------------------------------------------")
                print(self.tempCategories)
                print(item.category)
                print("-------------------------item---------------------------------------")
            }
            
            print("cat 1\(self.tempCategories1)")
            print(self.tempCategories)
            
            for category in self.categories {
                var count = 0
                for tempCategory in self.tempCategories {
                    if category.category == tempCategory {
                      
                        count += 1
                        category.ref?.updateChildValues(["counter" : count])
                    }
            
                }
            }
            self.tempCategories = []
            self.tempCategories1 = []
          
        })
        
        ref1.observe(.value, with: { snapshot in
            print("*********************")
            print(self.selectedCategory)
          print(snapshot.value as Any)
            print("*********************")
            
            
        })

        //MARK: - Download grocery items from database
        ref1.queryOrdered(byChild: "completed").observe(.value, with: { snapshot in
            //MARK: - Populate a list of grocery items to download
            var newCategories: [Category] = []
            for child in snapshot.children {
                //MARK: - Create snapshot which will be a child of all of our snapshots
                if let snapshot = child as? DataSnapshot,
                   //MARK: - Create grocery item from downloaded snapshot, add to list
                   let cat = Category(snapshot: snapshot) {
                    newCategories.append(cat)
                }
            }
            //MARK: - Set items in table to newItems
            self.categories = newCategories
            self.CategoriesCollection.reloadData()
            print("**************eeeee**")
            print(newCategories)
            print("*************eeeee***")
           
           
            
            for category in self.categories {
                self.tempCategories1.append(category.category)
                print("--------------------category--------------------------------------------")
                print(category.category)
                print("-----------------------category-----------------------------------------")
            }
            
        })
        
        
       
        
    }

   
    
    override func viewDidDisappear(_ animated: Bool) {
        refObservers.forEach(ref.removeObserver(withHandle:))
        refObservers = []

    }

    @IBAction func addNewCategoryClicked(_ sender: Any) {
        var emoji = UITextField()
        var nameField = UITextField()
        let alert = UIAlertController(title: "Add new category", message: "", preferredStyle: .alert)

        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in

            let name = nameField.text!
            let emoji = emoji.text!
            
            
            if self.cardCounter <= 3 {
                self.cardCounter += 1
            } else {
                self.cardCounter = 1
            }
            
            
            let category = Category(category: name, emoji: emoji, cardNumber: self.cardCounter, counter: 0)
            
            //MARK: - Ref to snapshot of grocery list
            let categoryRef = self.ref1.child(name.lowercased())
            
            categoryRef.setValue(category.toAnyObject())
           

        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Name"
            nameField = alertTextField
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Emoji"
            emoji = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func saveCategory(category: Category){
        
    }
    
    @objc func toAddToDo(){
        performSegue(withIdentifier: "toAddToDo", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! AddTaskViewController
        vc.categories = categories
        vc.delegate = self
    }

}

extension ListsViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(items.count)
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath) as! TableViewCell
        
        //MARK: - Each grocery item will fill the table
        let groceryItem = items[indexPath.row]
        
        //MARK: - Grocery item name and which user added it
        cell.itemName.text = groceryItem.name
        cell.itemQuantity.text = "\(groceryItem.quantity)"
        
     //   toggleCellCheckBox(cell, isCompleted: groceryItem.completed)

        return cell
    }
    
    
}
extension ListsViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoriesCell", for: indexPath) as! CollectionViewCell
        cell.categoryImage.image = UIImage(named: "rec\(categories[indexPath.row].cardNumber)")
        cell.categoryNameLabel.text = categories[indexPath.row].category
        cell.emojiLabel.text = categories[indexPath.row].emoji
        cell.counter.text = "\(categories[indexPath.row].counter)"
        return cell
    }
    
  
    
    
}
