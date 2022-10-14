//
//  ListsViewController.swift
//  My Dolphine
//
//  Created by Parth Antala on 2022-09-30.
//

import UIKit
import Firebase
import CoreData

class ListsViewController: UIViewController, selectedCategories, UIGestureRecognizerDelegate {
    
    
    var category = [Categories]()
    var categorySorted = [Categories]()
    var itemc = [Items]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
   
    @IBOutlet weak var addCatButton: UIButton!
    //arrays for table sections
    var doneItem: [Items] = []
    var notDoneItem: [Items] = []
    var sections = [tableCat]()
    
    let searchController = UISearchController()
    //array for filtered by search items
    var FilteredItems: [Items] = []
    
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
    var selectedItem: Items?
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
    
    var refreshControl:UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let apprence = UserDefaults.standard.integer(forKey: "apperence")
        
        if apprence == 1 {
            let window = UIApplication.shared.keyWindow
            window?.overrideUserInterfaceStyle = .dark
        } else if apprence == 2 {
            let window = UIApplication.shared.keyWindow
            window?.overrideUserInterfaceStyle = .light
        } else {
            let window = UIApplication.shared.keyWindow
            window?.overrideUserInterfaceStyle = .unspecified
        }
        
        
        loadCategory()
        loadItem()
        
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
       
        tableview.reloadData()
        CategoriesCollection.reloadData()
       
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.red
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        
        let timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(refresh), userInfo: nil, repeats: true)
        tableview.addSubview(refreshControl)
        
    }
    
    @objc func refresh(sender: AnyObject){
       // this function will be called whenever you pull your list for refresh
        loadItem()
        loadCategory()
        tableview.reloadData()
        refreshControl.endRefreshing()
    }

    func loadCategory(with request: NSFetchRequest<Categories> = Categories.fetchRequest()){
        //let request: NSFetchRequest<Item> = Item.fetchRequest()
        do {
        category = try context.fetch(request)
//            if category.isEmpty {
//                let newCategory = Categories(context: self.context)
//                newCategory.name = "General"
//                newCategory.emoji = "🏡"
//                newCategory.cardNumber = 6
//                newCategory.counter = 0
//                self.category.append(newCategory)
//                self.saveCategory()
//            }
            
            categorySorted = category.sorted(by: { $0.name!.lowercased() < $1.name!.lowercased()})
            print(categorySorted)
        } catch {
            print("error fetching data")
        }
        tableview.reloadData()
        CategoriesCollection.reloadData()
    }
    
    func loadItem(with request: NSFetchRequest<Items> = Items.fetchRequest()){
        doneItem = []
        notDoneItem = []
        do {
        itemc = try context.fetch(request)
            for i in itemc {
                print(i)
                if i.isDone {
                    doneItem.append(i)
                    print(doneItem)
                } else {
                    notDoneItem.append(i)
                    print(notDoneItem)
                }
            }
            
        self.sections = [tableCat(name: "to do", items: self.notDoneItem), tableCat(name: "done", items: self.doneItem)]
            
        } catch {
            print("error fetching data")
        }
        tableview.reloadData()
        CategoriesCollection.reloadData()
    }


    
    override func viewWillAppear(_ animated: Bool) {

        doneItem = []
        notDoneItem = []
        loadItem()
        loadCategory()
        tableview.reloadData()
        
        navigationController?.navigationBar.prefersLargeTitles = false
            
       updateCollection()
        let guide = UserDefaults.standard.integer(forKey: "guide")
        if guide != 1 {
            performSegue(withIdentifier: "toGuide", sender: self)
            UserDefaults.standard.set(1, forKey: "guide")
        }
    }

    func updateCollection() {
        loadCategory()
        tableview.reloadData()
        tempCategories = []
        for item in itemc {
            tempCategories.append(item.category ?? "nil")
        }
        
        for cat in category {
            var count = 0
            cat.counter = Int16(count)
            for tempCategory in self.tempCategories {
                if cat.name == tempCategory {
                    
                    count += 1
                    cat.counter = Int16(count)
                  
                    saveCategory()
                }
            }
            
        }
        tempCategories = []
        
        tableview.reloadData()
        CategoriesCollection.reloadData()
    }
    override func viewDidAppear(_ animated: Bool) {
        doneItem = []
        notDoneItem = []
        loadItem()
        tableview.reloadData()
    }
   
    override func viewDidDisappear(_ animated: Bool) {
        doneItem = []
        notDoneItem = []
        loadItem()
        tableview.reloadData()
    }
    override func viewWillDisappear(_ animated: Bool) {
    }

    
    @IBAction func addNewCategoryClicked(_ sender: Any) {
        var emoji = UITextField()
        var nameField = UITextField()
        
        let alert = UIAlertController(title: "Add new category", message: "", preferredStyle: .alert)

        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in

            let name = nameField.text!
            let emoji = emoji.text!
            
            self.cardCounter = Int.random(in: 1..<7)
            
            let newCategory = Categories(context: self.context)
            newCategory.name = name
            newCategory.emoji = emoji
            newCategory.cardNumber = Int16(self.cardCounter)
            newCategory.counter = 0
            self.category.append(newCategory)
            self.saveCategory()
           

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
        
        
        tableview.reloadData()
    }
    
    func saveCategory(){
       
        do{
            
            try
                context.save()
                print("data saved")
            loadCategory()
            
        } catch {
           print("error saving data")
        }
        self.tableview.reloadData()
    }
     
    func saveItem(){
       
        do{
            
            try
                context.save()
                print("data saved")
            self.tableview.reloadData()
            
        } catch {
           print("error saving data")
        }
        self.tableview.reloadData()
        doneItem = []
        notDoneItem = []
        loadItem()
    }
    
    func deleteCat(cat: Categories) {
       
                context.delete(cat)
        CategoriesCollection.reloadData()
        loadCategory()

        do {
            try context.save()
        } catch {
            //Handle error
        }
    }
    
    func deleteItem(item: Items) {
       
        context.delete(item)
        tableview.reloadData()
        doneItem = []
        notDoneItem = []

        
        loadItem()
        loadCategory()
        

        do {
            try context.save()
            updateCollection()
            CategoriesCollection.reloadData()
        } catch {
            //Handle error
        }
    }
    
    @objc func toAddToDo(){
        performSegue(withIdentifier: "toAddToDo", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? AddTaskViewController{
            vc.categories = category
            vc.delegate = self
        }
        else if let vc1 = segue.destination as? CategoryItemViewController {
            vc1.catName = catName
            vc1.catEmoji = catEmoji
            vc1.categories = category
        }
        else if let vc2 = segue.destination as? EditViewController {
            let indexPath = tableview.indexPathForSelectedRow
            vc2.selectedItem = selectedItem
            vc2.categories = category
        }
    }
    
    @IBAction func logoutClicked(_ sender: Any) {
        
        performSegue(withIdentifier: "toSetting", sender: self)

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

        var emoji = ""
        //MARK: - Grocery item name and which user added it
        cell.itemName.text = groceryItem.name
        cell.itemQuantity.text = "\(groceryItem.quantity)"
        
        for cats in category{
            
            if groceryItem.category == cats.name {
                if cats.emoji != "" {
                    emoji = cats.emoji!
                    cell.categoryLabel.text = cats.emoji
                }
                else{
                    cell.categoryLabel.text = groceryItem.category
                }
            }
        
        }
        
        if groceryItem.isDone {
//            doneItem = []
//            notDoneItem = []
            cell.CheckButton.setImage(UIImage(named: "CheckedOrange"), for: .normal)
            cell.itemName.textColor = UIColor.gray
            cell.itemQuantity.textColor = UIColor.gray
            cell.infoButtonAction = { [unowned self] in
                let cmt = groceryItem.note
                let alert = UIAlertController(title: "\(groceryItem.name ?? "item") \(emoji)", message: "Note: \(cmt ?? "No note")", preferredStyle: .alert)
                  let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                  alert.addAction(okAction)
                  self.present(alert, animated: true, completion: nil)
                }
        } else {
//            doneItem = []
//            notDoneItem = []
            cell.CheckButton.setImage(UIImage(named: "UncheckedOrange"), for: .normal)
            cell.itemName.textColor = UIColor.init(named: "LabelColor")
            cell.itemQuantity.textColor = UIColor.init(named: "LabelColor")
            cell.infoButtonAction = { [unowned self] in
                let cmt = groceryItem.note
                let alert = UIAlertController(title: "\(groceryItem.name ?? "item") \(emoji)", message: "Note: \(cmt ?? "No note")", preferredStyle: .alert)
                  let okAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
                  alert.addAction(okAction)
                        
                  self.present(alert, animated: true, completion: nil)
                }
        }
        
       
//        doneItem = []
//        notDoneItem = []
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }
        
        let items = self.sections[indexPath.section].items
    
        let item = items[indexPath.row]
        
        item.isDone = !item.isDone
        saveItem()
       
        
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
          
          self.deleteItem(item: item)
          loadCategory()
          loadItem()
          
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
                self.loadItem()
            }
            let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash"), identifier: nil, discoverabilityTitle: nil,attributes: .destructive, state: .off) { (_) in

                let items = self.sections[index.section].items

                let item = items[index.row]
                
                self.deleteItem(item: item)
              
               
            }
            return UIMenu(title: "Options", image: nil, identifier: nil, options: UIMenu.Options.displayInline, children: [edit,delete])
        }
        return context
    }
    
}
extension ListsViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            //return categories.count
        print(category.count)
        return categorySorted.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoriesCell", for: indexPath) as! CollectionViewCell
        
        
        cell.categoryImage.image = UIImage(named: "rec\(categorySorted[indexPath.row].cardNumber)")
        cell.categoryNameLabel.text = categorySorted[indexPath.row].name
        cell.emojiLabel.text = categorySorted[indexPath.row].emoji
        cell.counter.text = "\(categorySorted[indexPath.row].counter)"
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        let cat = categorySorted[indexPath.row]
        catName = cat.name!
        catEmoji = cat.emoji!
        performSegue(withIdentifier: "categoryItemsVC", sender: self)
    }
    
  
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
            configureContextMenu(index: indexPath.row)
        }
     
    func configureContextMenu(index: Int) -> UIContextMenuConfiguration{
        let context = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { (action) -> UIMenu? in
            
            let edit = UIAction(title: "Edit", image: UIImage(systemName: "square.and.pencil"), identifier: nil, discoverabilityTitle: nil, state: .off) { (_) in
              
                
                
                let cat = self.categorySorted[index]
                if cat.name == "General" {
                    let refreshAlert = UIAlertController(title: "Can not Update", message: "General Category can not be updated.", preferredStyle: UIAlertController.Style.alert)
       
                        refreshAlert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: { (action: UIAlertAction!) in
                        
                               refreshAlert .dismiss(animated: true, completion: nil)
                      }))
       
                       self.present(refreshAlert, animated: true, completion: nil)
                } else {
                    var emoji = UITextField()
                    var nameField = UITextField()
                    
                    
                    
                    let alert = UIAlertController(title: "Update category", message: "", preferredStyle: .alert)
                    
                    let action = UIAlertAction(title: "Update Category", style: .default) { (action) in
                        
                        let name = nameField.text!
                        let emoji = emoji.text!
                        
                        let cat = self.categorySorted[index]
                        cat.name = name
                        cat.emoji = emoji
                        self.saveCategory()
                        
                    }
                    
                    alert.addTextField { (alertTextField) in
                        alertTextField.placeholder = "Name"
                        alertTextField.text = self.categorySorted[index].name
                        
                        nameField = alertTextField
                    }
                    alert.addTextField { (alertTextField) in
                        alertTextField.placeholder = "Emoji"
                        alertTextField.text = self.categorySorted[index].emoji
                        emoji = alertTextField
                    }
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                }
            }
            let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash"), identifier: nil, discoverabilityTitle: nil,attributes: .destructive, state: .off) { (_) in
                
                let cat = self.categorySorted[index]
//                if cat.name == "General" {
//                    let refreshAlert = UIAlertController(title: "Can not Delete", message: "General Category can not be deleted.", preferredStyle: UIAlertController.Style.alert)
//
//                        refreshAlert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: { (action: UIAlertAction!) in
//
//                               refreshAlert .dismiss(animated: true, completion: nil)
//                      }))
//
//                       self.present(refreshAlert, animated: true, completion: nil)
//                } else {
                    self.deleteCat(cat: cat)
               // }
            }
            return UIMenu(title: "Options", image: nil, identifier: nil, options: UIMenu.Options.displayInline, children: [edit,delete])
        }
        return context
    }

  
    
    
}

extension ListsViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            FilteredItems = itemc

            for item in FilteredItems {
                if item.isDone {
                    self.doneItem.append(item)
                } else {
                    self.notDoneItem.append(item)
                }
            }

            sections = [tableCat(name: "to do", items: notDoneItem), tableCat(name: "done", items: doneItem)]

            tableview.reloadData()
        } else {
            FilteredItems = []
            FilteredItems = itemc.filter { $0.name!.lowercased().contains(searchText.lowercased()) == true }
            print(FilteredItems)

            doneItem = []
            notDoneItem = []

            for item in FilteredItems {
                if item.isDone {
                    self.doneItem.append(item)
                } else {
                    self.notDoneItem.append(item)
                }
            }

            sections = [tableCat(name: "to do", items: notDoneItem), tableCat(name: "done", items: doneItem)]

            tableview.reloadData()
        }
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


