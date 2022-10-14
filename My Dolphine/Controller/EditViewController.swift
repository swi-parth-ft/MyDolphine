//
//  EditViewController.swift
//  My Dolphine
//
//  Created by Parth Antala on 2022-10-03.
//

import UIKit
import Firebase
import CoreData

class EditViewController: UIViewController, selectedCat {

    var items = [Items]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var quantity = 0
    var newCategory = ""
    var selectedItem: Items?
    var user: User?
    var categories: [Categories] = []
    var cats: [String] = []
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var quantityText: UITextField!
    
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var notes: UITextField!
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
        navigationItem.largeTitleDisplayMode = .never
        updateButton.setTitle("", for: .normal)
        stepper.value = Double(selectedItem?.quantity ?? 0)
        self.hideKeyboardWhenTappedAround()
        
        nameText.text = selectedItem?.name
        quantityText.text = "Quantity: \(selectedItem?.quantity ?? 0)"
        notes.text = selectedItem?.note
        for category in categories {
            cats.append(category.name!)
        }
        
        selectCatButton.setTitle(selectedItem?.category, for: .normal)
        newCategory = selectedItem!.category!
    
     
        
    }
    

    override func viewDidAppear(_ animated: Bool) {
        print(cats)
        let i1 = cats.firstIndex(where: {$0 == selectedItem!.category})

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

        let note = notes.text!

        
        selectedItem!.name = name
        selectedItem?.category = newCategory
        selectedItem?.note = note
        selectedItem?.quantity = Int64(quantity)
    
        self.saveItem()
        
        self.navigationController?.popViewController(animated: true)
//        self.dismiss(animated: true)
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
}


