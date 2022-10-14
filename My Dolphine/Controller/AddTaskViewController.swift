//
//  AddTaskViewController.swift
//  My Dolphine
//
//  Created by Parth Antala on 2022-09-30.
//

import UIKit
import Firebase
import CoreData

protocol selectedCategories {
    func setCategory(category: String)
}

class AddTaskViewController: UIViewController, selectedCat {
   
    
    var items = [Items]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var selectCatButton: UIButton!
    var quantity = 0
    var delegate: selectedCategories?
    
    var categories: [Categories] = []
    var selectedCategory = ""
    var item: [Task] = []
    
    @IBOutlet weak var notes: UITextField!
    let ref = Database.database().reference(withPath: "items")
    let usersRef = Database.database().reference(withPath: "online")
    
    var refObservers: [DatabaseHandle] = []
    var handle: AuthStateDidChangeListenerHandle?
    
    var user: User!
    func setCategory(category: String) {
        selectedCategory = category
        selectCatButton.setTitle(selectedCategory, for: .normal)
    }
    
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var quantityText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
     
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.sizeToFit()
        
        Auth.auth().addStateDidChangeListener { auth, user in
            guard let user = user else { return }
            self.user = User(authData: user)
        
            let currentUserRef = self.usersRef.child(self.user.uid)
            currentUserRef.setValue(self.user.email)
            currentUserRef.onDisconnectRemoveValue()
        }

    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        print(selectedCategory)
    }
    
    
    @IBAction func stepperTapped(_ sender: Any) {
        quantityText.text = "Quantity: \(Int(stepper.value))"
        quantity = Int(stepper.value)
    }
    
    @IBAction func saveClicked(_ sender: Any) {

        var name = nameText.text
        if name == "" {
            name = "item"
        }
        
        if selectedCategory == "" {
            selectedCategory = "General"
        }
            
        var note = notes.text
        if note == "" {
            note = "No note!"
        }
        
        let newItem = Items(context: self.context)
        newItem.name = name
        newItem.category = selectedCategory
        newItem.note = note
        newItem.quantity = Int64(quantity)
        newItem.isDone = false
        self.items.append(newItem)
        self.saveItem()
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func saveItem(){
       
        do{
            
            try
                context.save()
                print("data saved")
            
        } catch {
           print("error saving data")
        }
    }
  
    override func viewWillAppear(_ animated: Bool) {
        print(selectedCategory)
    }
    
    @IBAction func selectCatClicked(_ sender: Any) {
        performSegue(withIdentifier: "selectCat", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? SelectCatViewController{
            vc.categories = categories
            vc.delegate = self
        }
    
    }
    
    
}

extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}
