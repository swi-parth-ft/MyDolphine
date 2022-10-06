//
//  ListsViewController.swift
//  My Dolphine
//
//  Created by Parth Antala on 2022-09-30.
//

import UIKit
import Firebase

class ListsViewController: UIViewController, selectedCategories, UIGestureRecognizerDelegate {
    
   
    @IBOutlet weak var addCatButton: UIButton!
    //arrays for table sections
    var doneItem: [Task] = []
    var notDoneItem: [Task] = []
    var sections = [tableCat]()
    
    let searchController = UISearchController()
    //array for filtered by search items
    var FilteredItems: [Task] = []
    
    @IBOutlet weak var searchBar: UISearchBar!
    
 //   var active = false
    
    //temp arrays to count category items
    var tempCategories:[String] = []
    var tempCategories1:[String] = []
    
    //card counter for category background card
    var cardCounter = 1
    var selectedCategory: String = ""
    var catName: String = ""
    var catEmoji: String = ""
    var selectedItem: Task?
    func setCategory(category: String) {
        print(category)
        selectedCategory = category
    }
    
    var user: User!
    
    
    @IBOutlet weak var CategoriesCollection: UICollectionView!
    var imageArray = [UIImage(named: "workToDoImage"),UIImage(named: "workToDoImage"),UIImage(named: "workToDoImage")]
    let addButton = UIButton()
    
    var categories: [Category] = []
    var items: [Task] = []
    
    let ref = Database.database().reference(withPath: "items")
    let ref1 = Database.database().reference(withPath: "categories")
    let usersRef = Database.database().reference(withPath: "online")
    
    var refObservers: [DatabaseHandle] = []
    var handle: AuthStateDidChangeListenerHandle?
    var longPressGesture: UILongPressGestureRecognizer!
    @IBOutlet weak var tableview: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
      
        
       
        searchBar.delegate = self
        self.hideKeyboardWhenTappedAround() 
        print(selectedCategory)
        
        addButton.setTitle("", for: .normal)
        addButton.setImage(UIImage(named: "addToDo"), for: .normal)
        self.view.addSubview(addButton)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.topAnchor.constraint(greaterThanOrEqualToSystemSpacingBelow: view.topAnchor, multiplier: 50).isActive = true
        addButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10).isActive = true
        addButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        addButton.addTarget(self, action: #selector(toAddToDo), for: .touchUpInside)
        
        tableview.delegate = self
        tableview.dataSource = self
        tableview.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "ReusableCell")
        tableview.backgroundColor = UIColor.systemGray6
        
        
        
        
        CategoriesCollection.delegate = self
        CategoriesCollection.dataSource = self

        navigationItem.hidesBackButton = true
       
        
        
        Auth.auth().addStateDidChangeListener { auth, user in
            //MARK: - Listen for online users, set currently logged in user
            guard let user = user else { return }
            self.user = User(authData: user)
        
            let currentUserRef = self.usersRef.child(self.user.uid)
            currentUserRef.setValue(self.user.email)
            currentUserRef.onDisconnectRemoveValue()
        }
       
        
    }
    

    

    
    override func viewWillAppear(_ animated: Bool) {
        
        doneItem = []
        notDoneItem = []
        tableview.reloadData()
            navigationController?.navigationBar.prefersLargeTitles = false
            ref.observe(.value, with: { snapshot in
                print(snapshot.value as Any)
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
                      
                        if groceryItem.addedByUser == self.user.uid{
                            
                            newItems.append(groceryItem)
                        }
                    }
                }
                //MARK: - Set items in table to newItems
                self.items = newItems
                self.FilteredItems = self.items
                
                self.doneItem = []
                self.notDoneItem = []
                
                for item in self.items {
                    if item.done {
                        self.doneItem.append(item)
                    } else {
                        self.notDoneItem.append(item)
                    }
                }
                
  
                    self.sections = [tableCat(name: "to do", items: self.notDoneItem), tableCat(name: "done", items: self.doneItem)]
                
                
                
                self.tableview.reloadData()
                for item in self.items {
                    self.tempCategories.append(item.category)
                }
                
                self.tableview.reloadData()
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
                
                
                for category in self.categories {
                    if category.category != "General" {
                        let category = Category(category: "General", emoji: "🏡", cardNumber: 6, counter: 0, addedByUser: self.user.uid)
                        
                        //MARK: - Ref to snapshot of grocery list
                        let categoryRef = self.ref1.child("General".lowercased())
                        
                        categoryRef.setValue(category.toAnyObject())
                    }
                }
         
             
                
            })
            
            ref1.observe(.value, with: { snapshot in
                print(snapshot.value as Any)
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
                        if cat.addedByUser == self.user.uid{
                            newCategories.append(cat)
                        }
                        
                    }
                }
                //MARK: - Set items in table to newItems
                self.categories = newCategories
                self.CategoriesCollection.reloadData()
                
                
                
                for category in self.categories {
                    self.tempCategories1.append(category.category)
                }
                
            })
            
        tableview.reloadData()
        CategoriesCollection.reloadData()
       
        
    }

   
    
    override func viewDidDisappear(_ animated: Bool) {
        refObservers.forEach(ref.removeObserver(withHandle:))
        refObservers = []
        doneItem = []
        notDoneItem = []
    }

    override func viewDidAppear(_ animated: Bool) {
        doneItem = []
        notDoneItem = []
    }
    
    @IBAction func addNewCategoryClicked(_ sender: Any) {
        var emoji = UITextField()
        var nameField = UITextField()
        
        let alert = UIAlertController(title: "Add new category", message: "", preferredStyle: .alert)

        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in

            let name = nameField.text!
            let emoji = emoji.text!
            
            
            if self.cardCounter < 7 {
                self.cardCounter += 1
            } else {
                self.cardCounter = 1
            }
            
            let category = Category(category: name, emoji: emoji, cardNumber: self.cardCounter, counter: 0, addedByUser: self.user.uid)
            
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
        
        let action1 = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                    print("Handle Cancel Logic here")
                    alert.dismiss(animated: true, completion: nil)
           })
        alert.addAction(action)
        alert.addAction(action1)
        present(alert, animated: true, completion: nil)
    }
    
    func saveCategory(category: Category){
        
    }
    
    @objc func toAddToDo(){
        performSegue(withIdentifier: "toAddToDo", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? AddTaskViewController{
            vc.categories = categories
            vc.delegate = self
        }
        else if let vc1 = segue.destination as? CategoryItemViewController {
            vc1.catName = catName
            vc1.catEmoji = catEmoji
            vc1.categories = categories
        }
        else if let vc2 = segue.destination as? EditViewController {
            let indexPath = tableview.indexPathForSelectedRow
            vc2.selectedItem = selectedItem
            vc2.categories = categories
        }
    }
    
    @IBAction func logoutClicked(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
            self.navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
    }
    
}

extension ListsViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
            return self.sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section].name
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(items.count)
        let items = self.sections[section].items
        if doneItem.count == 0 && notDoneItem.count == 0 {
            let emptyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
            
            let imageAttachment = NSTextAttachment()
            imageAttachment.image = UIImage(systemName: "plus.circle.fill")

            // If you want to enable Color in the SF Symbols.
            imageAttachment.image = UIImage(systemName: "plus.circle.fill")?.withTintColor(.blue)

            let fullString = NSMutableAttributedString(string: "Start adding items by tapping ")
            fullString.append(NSAttributedString(attachment: imageAttachment))
            fullString.append(NSAttributedString(string: " in bottom"))
            emptyLabel.attributedText = fullString
            
                //   emptyLabel.text = "Start adding items by tapping + in bottom"
                   emptyLabel.textAlignment = NSTextAlignment.center
                   self.tableview.backgroundView = emptyLabel
                   self.tableview.separatorStyle = UITableViewCell.SeparatorStyle.none
                   return 0
        } else {
            self.tableview.backgroundView = nil
            return items.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath) as! TableViewCell
        
        
        let items = self.sections[indexPath.section].items
        let groceryItem = items[indexPath.row]

        
        //MARK: - Grocery item name and which user added it
        cell.itemName.text = groceryItem.name
        cell.itemQuantity.text = "\(groceryItem.quantity)"
        if groceryItem.done {
            doneItem = []
            notDoneItem = []
            cell.CheckButton.setImage(UIImage(named: "CheckedOrange"), for: .normal)
            cell.itemName.textColor = UIColor.gray
            cell.itemQuantity.textColor = UIColor.gray
        } else {
            doneItem = []
            notDoneItem = []
            cell.CheckButton.setImage(UIImage(named: "UncheckedOrange"), for: .normal)
            cell.itemName.textColor = UIColor.init(named: "LabelColor")
            cell.itemQuantity.textColor = UIColor.init(named: "LabelColor")
        }
        
        for cats in categories{
            
            if groceryItem.category == cats.category {
                if cats.emoji != "" {
                    cell.categoryLabel.text = cats.emoji
                }
                else{
                    cell.categoryLabel.text = groceryItem.category
                }
            }
        
        }
        doneItem = []
        notDoneItem = []
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }
        
        let items = self.sections[indexPath.section].items
    
        let item = items[indexPath.row]
        
        let toggleCompletion = !item.done
        item.ref?.updateChildValues(["done" : toggleCompletion])
        doneItem = []
        notDoneItem = []
        print(searchController.isActive)
    }
    
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
      if editingStyle == .delete {
   
          guard let cell = tableView.cellForRow(at: indexPath) else {
              return
          }
          let items = self.sections[indexPath.section].items
      
          let item = items[indexPath.row]
          item.ref?.removeValue()
          CategoriesCollection.reloadData()
          tableview.reloadData()
      }
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        configureTableContextMenu(index: indexPath)
    }
    
    
  
    func configureTableContextMenu(index: IndexPath) -> UIContextMenuConfiguration{
        let context = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { (action) -> UIMenu? in

            let edit = UIAction(title: "Edit", image: UIImage(systemName: "square.and.pencil"), identifier: nil, discoverabilityTitle: nil, state: .off) { (_) in

                let items = self.sections[index.section].items

                let item = items[index.row]
         
                self.selectedItem = item
                self.performSegue(withIdentifier: "updateItem", sender: self)
            }
            let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash"), identifier: nil, discoverabilityTitle: nil,attributes: .destructive, state: .off) { (_) in

                let items = self.sections[index.section].items

                let item = items[index.row]
                item.ref?.removeValue()
               
            }
            return UIMenu(title: "Options", image: nil, identifier: nil, options: UIMenu.Options.displayInline, children: [edit,delete])
        }
        return context
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        let cat = categories[indexPath.row]
        catName = cat.category
        catEmoji = cat.emoji
        performSegue(withIdentifier: "categoryItemsVC", sender: self)
    }
    
  
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
            configureContextMenu(index: indexPath.row)
        }
     
    func configureContextMenu(index: Int) -> UIContextMenuConfiguration{
        let context = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { (action) -> UIMenu? in
            
            let edit = UIAction(title: "Edit", image: UIImage(systemName: "square.and.pencil"), identifier: nil, discoverabilityTitle: nil, state: .off) { (_) in
                print("edit button clicked")
                
                var emoji = UITextField()
                var nameField = UITextField()
                
               
                
                let alert = UIAlertController(title: "Update category", message: "", preferredStyle: .alert)
                
                let action = UIAlertAction(title: "Update Category", style: .default) { (action) in

                    
                    
                    let name = nameField.text!
                    let emoji = emoji.text!
                    
                    let cat = self.categories[index]
                    cat.ref?.updateChildValues(["category" : name])
                    cat.ref?.updateChildValues(["emoji" : emoji])
                   

                }
                alert.addTextField { (alertTextField) in
                    alertTextField.placeholder = "Name"
                    alertTextField.text = self.categories[index].category
                    
                    nameField = alertTextField
                }
                alert.addTextField { (alertTextField) in
                    alertTextField.placeholder = "Emoji"
                    alertTextField.text = self.categories[index].emoji
                    emoji = alertTextField
                }
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
      
            }
            let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash"), identifier: nil, discoverabilityTitle: nil,attributes: .destructive, state: .off) { (_) in
                let cat = self.categories[index]
                if cat.category == "General"{
                    let refreshAlert = UIAlertController(title: "Can not Delete", message: "General Category can not be deleted.", preferredStyle: UIAlertController.Style.alert)
       
                   refreshAlert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: { (action: UIAlertAction!) in
                        
                               refreshAlert .dismiss(animated: true, completion: nil)
                      }))
       
                       self.present(refreshAlert, animated: true, completion: nil)
                } else {
                    cat.ref?.removeValue()
                }
            }
            return UIMenu(title: "Options", image: nil, identifier: nil, options: UIMenu.Options.displayInline, children: [edit,delete])
        }
        return context
    }

  
    
    
}

extension ListsViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            FilteredItems = items
            
            for item in FilteredItems {
                if item.done {
                    self.doneItem.append(item)
                } else {
                    self.notDoneItem.append(item)
                }
            }
            
            sections = [tableCat(name: "to do", items: notDoneItem), tableCat(name: "done", items: doneItem)]
            
            tableview.reloadData()
        } else {
            FilteredItems = []
            FilteredItems = items.filter { $0.name.lowercased().contains(searchText.lowercased()) == true }
            print(FilteredItems)
            
            doneItem = []
            notDoneItem = []
            
            for item in FilteredItems {
                if item.done {
                    self.doneItem.append(item)
                } else {
                    self.notDoneItem.append(item)
                }
            }
            
            sections = [tableCat(name: "to do", items: notDoneItem), tableCat(name: "done", items: doneItem)]
            
            tableview.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
       
    }
    
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}


