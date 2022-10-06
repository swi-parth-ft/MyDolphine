//
//  SettingsViewController.swift
//  My Dolphine
//
//  Created by Parth Antala on 2022-10-06.
//

import UIKit
import Firebase

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var tableView: UITableView!
    var modes = ["dark","light","Auto"]
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.backgroundColor = UIColor.systemGray6
        // Do any additional setup after loading the view.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "modeCell", for: indexPath)
        cell.textLabel?.text = modes[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
                cell.accessoryType = .checkmark

            }
        if modes[indexPath.row] == "dark" {
            let window = UIApplication.shared.keyWindow
            window?.overrideUserInterfaceStyle = .dark
        }
        else if modes[indexPath.row] == "dark" {
            let window = UIApplication.shared.keyWindow
            window?.overrideUserInterfaceStyle = .light
        }
        else {
            let window = UIApplication.shared.keyWindow
            window?.overrideUserInterfaceStyle = .unspecified
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .none
        }
    }
  
    @IBAction func logoutClicked(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
            self.navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
        
    }
    

}
