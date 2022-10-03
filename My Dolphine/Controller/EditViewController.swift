//
//  EditViewController.swift
//  My Dolphine
//
//  Created by Parth Antala on 2022-10-03.
//

import UIKit
import Firebase

class EditViewController: UIViewController {

    var newCategory = ""
    var selectedItem: Task?
    var user: User?
    var categories: [Category] = []
    @IBOutlet weak var categoryPicker: UIPickerView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var quantityText: UITextField!
    
    let ref = Database.database().reference(withPath: "items")
    let usersRef = Database.database().reference(withPath: "online")
    var refObservers: [DatabaseHandle] = []
    var handle: AuthStateDidChangeListenerHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(selectedItem)
        print(categories)
        
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        
        Auth.auth().addStateDidChangeListener { auth, user in
            //MARK: - Listen for online users, set currently logged in user
            guard let user = user else { return }
            self.user = User(authData: user)
        
            let currentUserRef = self.usersRef.child(self.user!.uid)
            currentUserRef.setValue(self.user?.email)
            currentUserRef.onDisconnectRemoveValue()
        }
        
    }
    

    @IBAction func updateClicked(_ sender: Any) {
        
        let name = nameText.text
        let quantity = Int(quantityText.text ?? "0") ?? 0
        
        let item = Task(name: name!, quantity: quantity, comment: "demo comment", category: newCategory, done: false, addedByUser: self.user!.uid)
        
        selectedItem?.ref?.updateChildValues(["name" : name])
        selectedItem?.ref?.updateChildValues(["quantity" : quantity])
        selectedItem?.ref?.updateChildValues(["category" : newCategory])
    }
}

extension EditViewController: UIPickerViewDelegate,UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row].category
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        newCategory = categories[row].category
        
    }
    
}
