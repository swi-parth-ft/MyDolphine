//
//  AddTaskViewController.swift
//  My Dolphine
//
//  Created by Parth Antala on 2022-09-30.
//

import UIKit
import Firebase

protocol selectedCategories {
    func setCategory(category: String)
}

class AddTaskViewController: UIViewController, selectedCat {
   
    
    @IBOutlet weak var selectCatButton: UIButton!
    var quantity = 0
    var delegate: selectedCategories?
    
    var categories: [Category] = []
    var selectedCategory = ""
    var item: [Task] = []
    
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
//    @IBOutlet weak var categoryPicker: UIPickerView!
    @IBOutlet weak var quantityText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        
        
        
        
        
        Auth.auth().addStateDidChangeListener { auth, user in
            //MARK: - Listen for online users, set currently logged in user
            guard let user = user else { return }
            self.user = User(authData: user)
        
            let currentUserRef = self.usersRef.child(self.user.uid)
            currentUserRef.setValue(self.user.email)
            currentUserRef.onDisconnectRemoveValue()
        }

    }
    
    override func viewDidAppear(_ animated: Bool) {
        
       // categoryPicker.selectRow(0, inComponent: 0, animated: true)
       // selectCatButton.setTitle(selectedCategory, for: .normal)
        print(selectedCategory)
    }
    
    
    @IBAction func stepperTapped(_ sender: Any) {
        quantityText.text = "Quantity: \(Int(stepper.value))"
        quantity = Int(stepper.value)
    }
    
    @IBAction func saveClicked(_ sender: Any) {
//        if selectedCategory == ""{
//            print("aefeafaefaff\(selectedCategory)")
//
//            selectedCategory = "General"
//
//            let refreshAlert = UIAlertController(title: "Select Caregory", message: "Please select category for your item.", preferredStyle: UIAlertController.Style.alert)
//
//            refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
//                        print("Handle Cancel Logic here")
//                        refreshAlert .dismiss(animated: true, completion: nil)
//               }))
//
//                self.present(refreshAlert, animated: true, completion: nil)
    //    } else {
            let name = nameText.text ?? "item"
        //    let quantity = Int(quantityText.text ?? "0") ?? 0
            
        if selectedCategory == "" {
            selectedCategory = "General"
        }
            
            
            let item = Task(name: name, quantity: quantity, comment: "demo comment", category: selectedCategory, done: false, addedByUser: self.user.uid)
            
            //MARK: - Ref to snapshot of grocery list
            let itemRef = self.ref.child(name.lowercased())
            
            itemRef.setValue(item.toAnyObject())
            
            
            
            self.navigationController?.popViewController(animated: true)
      //  }
    }
  
    override func viewWillAppear(_ animated: Bool) {
       // selectCatButton.setTitle(selectedCategory, for: .normal)
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
//
//extension AddTaskViewController: UIPickerViewDelegate, UIPickerViewDataSource{
//    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        return 1
//    }
//
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        return categories.count
//    }
//
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        return categories[row].category
//    }
//
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        selectedCategory = categories[row].category
//        delegate?.setCategory(category: selectedCategory)
//    }
//}
