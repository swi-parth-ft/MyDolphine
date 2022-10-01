//
//  AddTaskViewController.swift
//  My Dolphine
//
//  Created by Parth Antala on 2022-09-30.
//

import UIKit

protocol AddTask {
    func addTask(name: String, quantity: Int, comment: String)
}

class AddTaskViewController: UIViewController {
    var delegate: AddTask?
    var categories = ["home","kitchen","bathroom"]
    var selectedCategory = ""
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
        delegate?.addTask(name: name, quantity: quantity, comment: "emoji")
        
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
        return categories[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCategory = categories[row]
    }
}
