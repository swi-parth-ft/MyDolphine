//
//  ListsViewController.swift
//  My Dolphine
//
//  Created by Parth Antala on 2022-09-30.
//

import UIKit
import CoreData

class ListsViewController: UIViewController, selectedCategories, UIGestureRecognizerDelegate {
    
    
    var category = [Categories]()
    var categorySorted = [Categories]()
    var itemc = [Items]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var catCardNumber = 0
    //arrays for table sections
    var doneItem: [Items] = []
    var notDoneItem: [Items] = []
    var sections = [tableCat]()
    let searchController = UISearchController()
    //array for filtered by search items
    var FilteredItems: [Items] = []
    //temp arrays to count category items
    var tempCategories:[String] = []
    var tempCategories1:[String] = []
    //card counter for category background card
    var cardCounter = 1
    var selectedCategory: String = ""
    var catName: String = ""
    var catEmoji: String = ""
    var selectedItem: Items?
    let addButton = UIButton()
    var categories: [Category] = []
    var items: [Task] = []
    var longPressGesture: UILongPressGestureRecognizer!
    var refreshControl:UIRefreshControl!
    
    //MARK: - Outlets
    @IBOutlet weak var addCatButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var CategoriesCollection: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    func setCategory(category: String) {
        print(category)
        selectedCategory = category
    }
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let apprence = UserDefaults.standard.integer(forKey: "apperence")
        
        if apprence == 1 {
            let window = UIApplication.shared.keyWindow
            window?.overrideUserInterfaceStyle = .dark
            self.navigationController?.navigationBar.tintColor = UIColor.white
        } else if apprence == 2 {
            let window = UIApplication.shared.keyWindow
            window?.overrideUserInterfaceStyle = .light
            self.navigationController?.navigationBar.tintColor = UIColor.black
        } else {
            let window = UIApplication.shared.keyWindow
            window?.overrideUserInterfaceStyle = .unspecified
            if window?.overrideUserInterfaceStyle == .dark {
                self.navigationController?.navigationBar.tintColor = UIColor.white
            } else {
                self.navigationController?.navigationBar.tintColor = UIColor.black
            }
        }
        
        loadCategory()
        loadItem()
        
        navigationItem.hidesBackButton = true
        
        searchBar.delegate = self
        self.hideKeyboardWhenTappedAround()
        
        addButton.setTitle("", for: .normal)
        addButton.setImage(UIImage(named: "addToDo"), for: .normal)
        self.view.addSubview(addButton)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.topAnchor.constraint(greaterThanOrEqualToSystemSpacingBelow: view.topAnchor, multiplier: 50).isActive = true
        addButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10).isActive = true
        addButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        addButton.addTarget(self, action: #selector(toAddToDo), for: .touchUpInside)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "ReusableCell")
        tableView.layer.cornerRadius=13

        CategoriesCollection.delegate = self
        CategoriesCollection.dataSource = self

        tableView.reloadData()
        CategoriesCollection.reloadData()
        
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.red
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        
        //        let timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(refresh), userInfo: nil, repeats: true)
        tableView.addSubview(refreshControl)
    }
    
    //MARK: - viewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        doneItem = []
        notDoneItem = []
        loadItem()
        tableView.reloadData()
        CategoriesCollection.reloadData()
        
    }
    
    //MARK: - viewDidDisappear
    override func viewDidDisappear(_ animated: Bool) {
        doneItem = []
        notDoneItem = []
        loadItem()
        tableView.reloadData()
    }
    
    @objc func refresh(sender: AnyObject){
        loadItem()
        loadCategory()
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    //MARK: - load category
    func loadCategory(with request: NSFetchRequest<Categories> = Categories.fetchRequest()){
        do {
            category = try context.fetch(request)
            if category.isEmpty {
                let newCategory = Categories(context: self.context)
                newCategory.name = "General"
                newCategory.emoji = "????"
                newCategory.cardNumber = 6
                newCategory.counter = 0
                self.category.append(newCategory)
                self.saveCategory()
            }
            var cate: Categories?
            var count = 0
            for cat in category {
                cate = cat
                if cat.name == "General" {
                    count += 1
                }
            }
            
            if count > 1 {
                deleteCat(cat: cate!)
                count = 0
                loadCategory()
                CategoriesCollection.reloadData()
            }
            
            categorySorted = category.sorted(by: { $0.name!.lowercased() < $1.name!.lowercased()})
            print(categorySorted)
        } catch {
            print("error fetching data")
        }
        tableView.reloadData()
        CategoriesCollection.reloadData()
    }
    
    //MARK: - load items
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
        tableView.reloadData()
        CategoriesCollection.reloadData()
    }
    
    
    //MARK: - viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        
        doneItem = []
        notDoneItem = []
        loadItem()
        loadCategory()
        tableView.reloadData()
        
        navigationController?.navigationBar.prefersLargeTitles = false
        
        updateCollection()
        let guide = UserDefaults.standard.integer(forKey: "guide")
        if guide != 1 {
            performSegue(withIdentifier: "toGuide", sender: self)
            UserDefaults.standard.set(1, forKey: "guide")
        }
        
        
        let theme = UserDefaults.standard.integer(forKey: "theme")
        
        if theme == 1 {
            view.backgroundColor = .black
            CategoriesCollection.backgroundColor = .black
        } else {
            view.backgroundColor = .systemGray6
            CategoriesCollection.backgroundColor = .systemGray6
        }
    }
    
    //MARK: - update collection
    func updateCollection() {
        loadCategory()
        tableView.reloadData()
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
        
        tableView.reloadData()
        CategoriesCollection.reloadData()
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
        
        
        tableView.reloadData()
    }
    
    //MARK: - save category
    func saveCategory(){
        
        do{
            
            try
            context.save()
            print("data saved")
            loadCategory()
            
        } catch {
            print("error saving data")
        }
        self.tableView.reloadData()
    }
    
    //MARK: - save item
    func saveItem(){
        
        do{
            
            try
            context.save()
            print("data saved")
            self.tableView.reloadData()
            
        } catch {
            print("error saving data")
        }
        self.tableView.reloadData()
        doneItem = []
        notDoneItem = []
        loadItem()
    }
    
    //MARK: - delete category
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
    
    //MARK: - delete items
    func deleteItem(item: Items) {
        
        context.delete(item)
        tableView.reloadData()
        doneItem = []
        notDoneItem = []
        
        loadItem()
        loadCategory()
        
        do {
            try context.save()
            updateCollection()
            CategoriesCollection.reloadData()
        } catch {
            
        }
    }
    
    @objc func toAddToDo(){
        performSegue(withIdentifier: "toAddToDo", sender: self)
    }
    
    //MARK: - prepare for
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? AddTaskViewController{
            vc.categories = category
            vc.delegate = self
        }
        else if let vc1 = segue.destination as? CategoryItemViewController {
            vc1.catName = catName
            vc1.catEmoji = catEmoji
            vc1.categories = category
            vc1.catCardNumber = catCardNumber
        }
        else if let vc2 = segue.destination as? EditViewController {
            let indexPath = tableView.indexPathForSelectedRow
            vc2.selectedItem = selectedItem
            vc2.categories = category
        }
    }
    
    @IBAction func settingTapped(_ sender: Any) {
        performSegue(withIdentifier: "toSetting", sender: self)
    }
}

//MARK: - tableView extention
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
            imageAttachment.image = UIImage(systemName: "plus.circle.fill")?.withTintColor(.blue)
            
            let fullString = NSMutableAttributedString(string: "Start adding items by tapping ")
            fullString.append(NSAttributedString(attachment: imageAttachment))
            fullString.append(NSAttributedString(string: " in bottom"))
            emptyLabel.attributedText = fullString
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
        
        let items = self.sections[indexPath.section].items
        let item = items[indexPath.row]
        
        var emoji = ""
        cell.itemName.text = item.name
        cell.itemQuantity.text = "\(item.quantity)"
        
        for cats in category{
            if item.category == cats.name {
                if cats.emoji != "" {
                    emoji = cats.emoji!
                    cell.categoryLabel.text = cats.emoji
                }
                else{
                    cell.categoryLabel.text = item.category
                }
            }
        }
        
        if item.isDone {
            let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: item.name!)
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
            cell.itemName.attributedText = attributeString
            cell.CheckButton.setImage(UIImage(named: "CheckedOrange"), for: .normal)
            cell.itemName.textColor = UIColor.gray
            cell.itemQuantity.textColor = UIColor.gray
            cell.infoButtonAction = { [unowned self] in
                let cmt = item.note
                let alert = UIAlertController(title: "\(item.name ?? "item") \(emoji)", message: "Note: \(cmt ?? "No note")", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            }
            
        } else {
            
            let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: item.name!)
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: [], range: NSMakeRange(0, attributeString.length))
            cell.itemName.attributedText = attributeString
            
            cell.CheckButton.setImage(UIImage(named: "UncheckedOrange"), for: .normal)
            cell.itemName.textColor = UIColor.init(named: "LabelColor")
            cell.itemQuantity.textColor = UIColor.init(named: "LabelColor")
            cell.infoButtonAction = { [unowned self] in
                let cmt = item.note
                let alert = UIAlertController(title: "\(item.name ?? "item") \(emoji)", message: "Note: \(cmt ?? "No note")", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
                alert.addAction(okAction)
                
                self.present(alert, animated: true, completion: nil)
            }
        }
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
    }
    
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
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

//MARK: - collectionView extention
extension ListsViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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
        catCardNumber = Int(cat.cardNumber)
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
                let refreshAlert = UIAlertController(title: "Delete Category with items?", message: "Do you want delete items of \(cat.name ?? "this category") as well?", preferredStyle: UIAlertController.Style.alert)
                
                refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                    
                    
                    let refreshAlert = UIAlertController(title: "Delete", message: "Delete \(cat.name ?? "category") with all items?", preferredStyle: UIAlertController.Style.alert)
                    
                    refreshAlert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action: UIAlertAction!) in
                        
                        for item in self.itemc {
                            if item.category == cat.name {
                                self.deleteItem(item: item)
                            }
                        }
                        self.deleteCat(cat: cat)
                    }))
                    
                    refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                        print("Handle Cancel Logic here")
                    }))
                    
                    self.present(refreshAlert, animated: true, completion: nil)
                }))
                
                refreshAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
                    
                    let refreshAlert = UIAlertController(title: "Delete \(cat.name ?? "category")?", message: "All items in \(cat.name ?? "category") will move to General.", preferredStyle: UIAlertController.Style.alert)
                    
                    refreshAlert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action: UIAlertAction!) in
                        for item in self.itemc {
                            if item.category == cat.name {
                                item.category = "General"
                            }
                            self.saveItem()
                        }
                        self.deleteCat(cat: cat)
                        self.loadCategory()
                        self.loadItem()
                        self.tableView.reloadData()
                        self.CategoriesCollection.reloadData()
                    }))
                    
                    refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                        print("Handle Cancel Logic here")
                    }))
                    
                    self.present(refreshAlert, animated: true, completion: nil)
                    self.loadCategory()
                    self.CategoriesCollection.reloadData()
                }))
                
                self.present(refreshAlert, animated: true, completion: nil)
                self.loadCategory()
                self.CategoriesCollection.reloadData()
                
            }
            return UIMenu(title: "Options", image: nil, identifier: nil, options: UIMenu.Options.displayInline, children: [edit,delete])
        }
        self.loadCategory()
        self.CategoriesCollection.reloadData()
        return context
    }
}

//MARK: - searchBar extention
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
            
            tableView.reloadData()
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
            
            tableView.reloadData()
        }
    }
    
    
}

//MARK: - hide keyboard extention
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


