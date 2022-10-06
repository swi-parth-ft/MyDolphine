//
//  EditViewController.swift
//  My Dolphine
//
//  Created by Parth Antala on 2022-10-03.
//

import UIKit
import Firebase

class EditViewController: UIViewController, selectedCat {

    var quantity = 0
    var newCategory = ""
    var selectedItem: Task?
    var user: User?
    var categories: [Category] = []
    var cats: [String] = []
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var quantityText: UITextField!
    
    @IBOutlet weak var selectCatButton: UIButton!
    @IBOutlet weak var stepper: UIStepper!
    let ref = Database.database().reference(withPath: "items")
    let usersRef = Database.database().reference(withPath: "online")
    var refObservers: [DatabaseHandle] = []
    var handle: AuthStateDidChangeListenerHandle?
    
    func setCategory(category: String) {
        newCategory = category
        selectCatButton.setTitle(newCategory, for: .normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stepper.value = Double(selectedItem?.quantity ?? 0)
        self.hideKeyboardWhenTappedAround()
        
        nameText.text = selectedItem?.name
        quantityText.text = "Quantity: \(selectedItem?.quantity ?? 0)"
        
        for category in categories {
            cats.append(category.category)
        }
        
        selectCatButton.setTitle(selectedItem?.category, for: .normal)
        newCategory = selectedItem!.category
    
        
        Auth.auth().addStateDidChangeListener { auth, user in
            //MARK: - Listen for online users, set currently logged in user
            guard let user = user else { return }
            self.user = User(authData: user)
        
            let currentUserRef = self.usersRef.child(self.user!.uid)
            currentUserRef.setValue(self.user?.email)
            currentUserRef.onDisconnectRemoveValue()
        }
        
    }
    

    override func viewDidAppear(_ animated: Bool) {
        print(cats)
        let i1 = cats.firstIndex(where: {$0 == selectedItem!.category})
        print(i1!)
    }
    
    @IBAction func stepperTapped(_ sender: Any) {
        quantityText.text = "Quantity: \(Int(stepper.value))"
        quantity = Int(stepper.value)
    }
    
    
    @IBAction func selectCatClicked(_ sender: Any) {
        
        performSegue(withIdentifier: "selectCatFromEdit", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? SelectCatViewController{
            vc.categories = categories
            vc.delegate = self
        }
    
    }
    
    @IBAction func updateClicked(_ sender: Any) {
        
        let name = nameText.text
//        let quantity = Int(quantityText.text ?? "0") ?? 0
        
        let item = Task(name: name!, quantity: quantity, comment: "demo comment", category: newCategory, done: false, addedByUser: self.user!.uid)
        
        selectedItem?.ref?.updateChildValues(["name" : name])
        selectedItem?.ref?.updateChildValues(["quantity" : quantity])
        selectedItem?.ref?.updateChildValues(["category" : newCategory])
        
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true)
    }
}


