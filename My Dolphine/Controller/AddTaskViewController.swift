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

class AddTaskViewController: UIViewController {
    
    var delegate: selectedCategories?
    
    var categories: [Category] = []
    var selectedCategory = ""
    var item: [Task] = []
    
    let ref = Database.database().reference(withPath: "items")
    var refObservers: [DatabaseHandle] = []
    var handle: AuthStateDidChangeListenerHandle?
    
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var categoryPicker: UIPickerView!
    @IBOutlet weak var quantityText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        // Do any additional setup after loading the view.
    }
    

    
    @IBAction func saveClicked(_ sender: Any) {
        let name = nameText.text ?? "item"
        let quantity = Int(quantityText.text ?? "0") ?? 0
        
      
       
        let item = Task(name: name, quantity: quantity, comment: "demo comment", category: selectedCategory)
        
        //MARK: - Ref to snapshot of grocery list
        let itemRef = self.ref.child(name.lowercased())
        
        itemRef.setValue(item.toAnyObject())
        
        
        navigationController?.popViewController(animated: true)
    }
  

}

extension AddTaskViewController: UIPickerViewDelegate, UIPickerViewDataSource{
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
        selectedCategory = categories[row].category
        delegate?.setCategory(category: selectedCategory)
    }
}
