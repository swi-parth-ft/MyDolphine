//
//  CategoryItemViewController.swift
//  My Dolphine
//
//  Created by Parth Antala on 2022-10-03.
//

import UIKit
import Firebase

class CategoryItemViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let addButton = UIButton()
    var categories: [Category] = []
    //arrays for table sections
    var doneItem: [Task] = []
    var notDoneItem: [Task] = []
    var sections = [tableCat]()
    var selectedItem: Task?
    @IBOutlet weak var tableView: UITableView!
    var catName: String = ""
    var catEmoji: String = ""
    var user: User!
    let ref = Database.database().reference(withPath: "items")
    let usersRef = Database.database().reference(withPath: "online")
    var items: [Task] = []
    var refObservers: [DatabaseHandle] = []
    var handle: AuthStateDidChangeListenerHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.systemGray6
        navigationController?.navigationBar.prefersLargeTitles = true
        
        addButton.setTitle("", for: .normal)
        addButton.setImage(UIImage(named: "addToDo"), for: .normal)
        self.view.addSubview(addButton)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.topAnchor.constraint(greaterThanOrEqualToSystemSpacingBelow: view.topAnchor, multiplier: 50).isActive = true
        addButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10).isActive = true
        addButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        addButton.addTarget(self, action: #selector(toAddToDo), for: .touchUpInside)
        
        self.title = "\(catName) \(catEmoji)"
        Auth.auth().addStateDidChangeListener { auth, user in
            //MARK: - Listen for online users, set currently logged in user
            guard let user = user else { return }
            self.user = User(authData: user)
        
            let currentUserRef = self.usersRef.child(self.user.uid)
            currentUserRef.setValue(self.user.email)
            currentUserRef.onDisconnectRemoveValue()
        }
        
        tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "ReusableCell")
    }
    
    @objc func toAddToDo(){
        var name = UITextField()
        var quantity = UITextField()
        
        let alert = UIAlertController(title: "Add new item in \(catName)", message: "", preferredStyle: .alert)

        let action = UIAlertAction(title: "Add item", style: .default) { (action) in

            let name = name.text!
            let quantity = quantity.text!
            
            
         
            let item = Task(name: name, quantity: Int(quantity) ?? 0, comment: "demo comment", category: self.catName, done: false, addedByUser: self.user.uid)
            
            //MARK: - Ref to snapshot of grocery list
            let itemRef = self.ref.child(name.lowercased())
            
            itemRef.setValue(item.toAnyObject())
           

        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Name"
            name = alertTextField
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Quantity"
            quantity = alertTextField
        }
        
        let action1 = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                    print("Handle Cancel Logic here")
                    alert.dismiss(animated: true, completion: nil)
           })
        alert.addAction(action)
        alert.addAction(action1)
        present(alert, animated: true, completion: nil)
    }
    
    
     
     override func viewWillAppear(_ animated: Bool) {
         
         ref.observe(.value, with: { snapshot in
           
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
                     if groceryItem.category == self.catName{
                         if groceryItem.addedByUser == self.user.uid{
                             newItems.append(groceryItem)
                         }
                     }
                 }
             }
             //MARK: - Set items in table to newItems
             self.items = newItems
             self.tableView.reloadData()
             
             for item in self.items {
                 if item.done {
                     self.doneItem.append(item)
                 } else {
                     self.notDoneItem.append(item)
                 }
             }
             
             self.sections = [tableCat(name: "to do", items: self.notDoneItem), tableCat(name: "done", items: self.doneItem)]
             
             self.tableView.reloadData()
           
         })
         
        

      
         tableView.reloadData()
         
        
         
     }

    override func viewDidDisappear(_ animated: Bool) {
       
        doneItem = []
        notDoneItem = []
    }

    override func viewDidAppear(_ animated: Bool) {
        doneItem = []
        notDoneItem = []
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      
        let vc2 = segue.destination as? EditViewController
        let indexPath = tableView.indexPathForSelectedRow
        vc2!.selectedItem = selectedItem
        vc2!.categories = categories
        
    }
    
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
                   self.tableView.backgroundView = emptyLabel
                   self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
                   return 0
        } else {
            self.tableView.backgroundView = nil
            return items.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath) as! TableViewCell
        
        //MARK: - Each grocery item will fill the table
        let items = self.sections[indexPath.section].items
        let groceryItem = items[indexPath.row]
        
        var emoji = ""
        for cats in categories{
            
            if groceryItem.category == cats.category {
                if cats.emoji != "" {
                    emoji = cats.emoji
                   
                }
                else{
                   emoji = ""
                }
            }
        
        }
        
        //MARK: - Grocery item name and which user added it
        cell.itemName.text = groceryItem.name
        cell.itemQuantity.text = "\(groceryItem.quantity)"
        if groceryItem.done {
            doneItem = []
            notDoneItem = []
            cell.CheckButton.setImage(UIImage(named: "CheckedOrange"), for: .normal)
            cell.itemName.textColor = UIColor.gray
            cell.itemQuantity.textColor = UIColor.gray
            cell.infoButtonAction = { [unowned self] in
                let cmt = groceryItem.comment
                let alert = UIAlertController(title: "\(groceryItem.name) \(emoji)", message: "Note: \(cmt)", preferredStyle: .alert)
                  let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                  alert.addAction(okAction)
                        
                  self.present(alert, animated: true, completion: nil)
                }
        } else {
            doneItem = []
            notDoneItem = []
            cell.CheckButton.setImage(UIImage(named: "UncheckedOrange"), for: .normal)
            cell.itemName.textColor = UIColor.init(named: "LabelColor")
            cell.itemQuantity.textColor = UIColor.init(named: "LabelColor")
            cell.infoButtonAction = { [unowned self] in
                let cmt = groceryItem.comment
                let alert = UIAlertController(title: "\(groceryItem.name) \(emoji)", message: "Note: \(cmt)", preferredStyle: .alert)
                  let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                  alert.addAction(okAction)
                        
                  self.present(alert, animated: true, completion: nil)
                }
        }
        cell.categoryLabel.text = ""
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
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
      if editingStyle == .delete {
        print("Deleted")
          guard let cell = tableView.cellForRow(at: indexPath) else {
              return
          }
          let items = self.sections[indexPath.section].items
          let item = items[indexPath.row]
          item.ref?.removeValue()
          tableView.reloadData()
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
                self.performSegue(withIdentifier: "editFromCat", sender: self)
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
