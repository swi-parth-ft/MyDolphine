//
//  CategoryItemViewController.swift
//  My Dolphine
//
//  Created by Parth Antala on 2022-10-03.
//

import UIKit
import Firebase

class CategoryItemViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

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
                         newItems.append(groceryItem)
                     }
                 }
             }
             //MARK: - Set items in table to newItems
             self.items = newItems
             self.tableView.reloadData()
             
             
           
         })
         
        

      
         
         
        
         
     }


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
        if groceryItem.done {
            cell.CheckButton.setImage(UIImage(named: "CheckedOrange"), for: .normal)
        } else {
            cell.CheckButton.setImage(UIImage(named: "UncheckedOrange"), for: .normal)
        }
        cell.categoryLabel.text = groceryItem.category
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }
        let item = items[indexPath.row]
        let toggleCompletion = !item.done
        
        item.ref?.updateChildValues(["done" : toggleCompletion])
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
          
          let item = items[indexPath.row]
          item.ref?.removeValue()
        
      }
    }

}
