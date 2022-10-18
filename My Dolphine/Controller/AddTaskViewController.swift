//
//  AddTaskViewController.swift
//  My Dolphine
//
//  Created by Parth Antala on 2022-09-30.
//

import UIKit
import CoreData

protocol selectedCategories {
    func setCategory(category: String)
}

class AddTaskViewController: UIViewController, selectedCat, UITextFieldDelegate {
    
    var items = [Items]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var quantity = 0
    var delegate: selectedCategories?
    var categories: [Categories] = []
    var selectedCategory = ""
    var item: [Task] = []
    
    @IBOutlet weak var stepperView: UIView!
    @IBOutlet weak var selectCatButton: UIButton!
    @IBOutlet weak var notes: UITextField!
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var quantityText: UITextField!
    
    func setCategory(category: String) {
        selectedCategory = category
        selectCatButton.setTitle(selectedCategory, for: .normal)
    }
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameText.delegate = self
        nameText.tag = 0
        
        quantityText.delegate = self
        quantityText.tag = 1
        
        notes.delegate = self
        notes.tag = 2
        
        
        stepper.transform = stepper.transform.scaledBy(x: 1, y: 1.1)
        
        nameText.layer.cornerRadius = nameText.frame.size.height/4
        nameText.clipsToBounds = true
        
        quantityText.layer.cornerRadius = quantityText.frame.size.height/4
        quantityText.clipsToBounds = true
        
        notes.layer.cornerRadius = notes.frame.size.height/4
        notes.clipsToBounds = true
        
        selectCatButton.layer.cornerRadius = 5
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.sizeToFit()
    }
    
    //MARK: - viewWillAppear
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        let theme = UserDefaults.standard.integer(forKey: "theme")
        
        if theme == 1 {
            view.backgroundColor = .black
            stepperView.backgroundColor = .black
        } else {
            view.backgroundColor = .systemGray6
            stepperView.backgroundColor = .systemGray6
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameText {
            textField.resignFirstResponder()
            notes.becomeFirstResponder()
            
        } else if textField == notes {
            textField.resignFirstResponder()
            save()
        }
        return true
        
    }
    
    //MARK: - stepper tapped action
    @IBAction func stepperTapped(_ sender: Any) {
        quantityText.text = "\(Int(stepper.value))"
        quantity = Int(stepper.value)
    }
    
    //MARK: - save clicked
    @IBAction func saveClicked(_ sender: Any) {
        save()
    }
    
    //MARK: - save item function
    func save(){
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
    
    //MARK: - select cat clicked
    @IBAction func selectCatClicked(_ sender: Any) {
        performSegue(withIdentifier: "selectCat", sender: self)
        
    }
    
    //MARK: - prepare for
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? SelectCatViewController{
            vc.categories = categories
            vc.delegate = self
        }
    }
}

//MARK: - UITextField extention
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
