//
//  EditViewController.swift
//  My Dolphine
//
//  Created by Parth Antala on 2022-10-03.
//

import UIKit

import CoreData

class EditViewController: UIViewController, selectedCat, UITextFieldDelegate {
    
    var items = [Items]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var quantity = 0
    var newCategory = ""
    var selectedItem: Items?
    var categories: [Categories] = []
    var cats: [String] = []
    
    @IBOutlet weak var stepperView: UIView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var quantityText: UITextField!
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var notes: UITextField!
    @IBOutlet weak var selectCatButton: UIButton!
    @IBOutlet weak var stepper: UIStepper!
    
    
    func setCategory(category: String) {
        newCategory = category
        selectCatButton.setTitle(newCategory, for: .normal)
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
        
        nameText.layer.cornerRadius = nameText.frame.size.height/4
        nameText.clipsToBounds = true
        
        quantityText.layer.cornerRadius = quantityText.frame.size.height/4
        quantityText.clipsToBounds = true
        
        notes.layer.cornerRadius = notes.frame.size.height/4
        notes.clipsToBounds = true
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.sizeToFit()
        
        updateButton.setTitle("", for: .normal)
        stepper.value = Double(selectedItem?.quantity ?? 0)
        self.hideKeyboardWhenTappedAround()
        
        nameText.text = selectedItem?.name
        quantityText.text = "\(selectedItem?.quantity ?? 0)"
        notes.text = selectedItem?.note
        for category in categories {
            cats.append(category.name!)
        }
        
        selectCatButton.setTitle(selectedItem?.category, for: .normal)
        newCategory = selectedItem!.category!
    }
    
    //MARK: - viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        let theme = UserDefaults.standard.integer(forKey: "theme")
        
        if theme == 1 {
            view.backgroundColor = .black
            stepperView.backgroundColor = .black
        } else {
            view.backgroundColor = .systemGray6
            stepperView.backgroundColor = .systemGray6
        }
        
    }
    
    //MARK: - viewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        print(cats)
        let i1 = cats.firstIndex(where: {$0 == selectedItem!.category})
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameText {
            textField.resignFirstResponder()
            notes.becomeFirstResponder()
            
        } else if textField == notes {
            textField.resignFirstResponder()
        }
        return true
        
    }
    
   //MARK: - stepper tapped
    @IBAction func stepperTapped(_ sender: Any) {
        quantityText.text = "\(Int(stepper.value))"
        quantity = Int(stepper.value)
    }
    
    //MARK: - select cat clicked
    @IBAction func selectCatClicked(_ sender: Any) {
        performSegue(withIdentifier: "selectCatFromEdit", sender: self)
    }
    
    //MARK: - prepare for
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? SelectCatViewController{
            vc.categories = categories
            vc.delegate = self
        }
    }
    
    //MARK: - update clicked
    @IBAction func updateClicked(_ sender: Any) {
        
        let name = nameText.text
        let note = notes.text!
        
        selectedItem!.name = name
        selectedItem?.category = newCategory
        selectedItem?.note = note
        selectedItem?.quantity = Int64(quantity)
        self.saveItem()
        
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - save item
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


