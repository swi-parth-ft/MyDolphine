//
//  ViewController.swift
//  My Dolphine
//
//  Created by Parth Antala on 2022-09-30.
//

import UIKit
import FirebaseAuth
import CoreData

class ViewController: UIViewController {

    
   
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var homeIDTextView: UITextField!
    @IBOutlet weak var passkeyTextView: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loginButton.setTitle("", for: .normal)
        passkeyTextView.isSecureTextEntry = true
        Auth.auth().addStateDidChangeListener { auth, user in
                if user != nil{
                    // User is signed in.
                    print("User is not logged out.")
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "loggedIn", sender: nil)
                    }
                    
                } else {
                    print("No user is signed in.")
                }
            }
        
    }

    @IBAction func loginButtonClicked(_ sender: Any) {
        if let id = homeIDTextView.text, let passkey = passkeyTextView.text {
            Auth.auth().signIn(withEmail: id, password: passkey) { authResult, error in
                if let e = error {
                    let refreshAlert = UIAlertController(title: "Invalid Credentials", message: "HomeID or Passkey is incorrect.", preferredStyle: UIAlertController.Style.alert)
                   
                    refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                                print("Handle Cancel Logic here")
                                refreshAlert .dismiss(animated: true, completion: nil)
                       }))

                        self.present(refreshAlert, animated: true, completion: nil)
                } else {
                   // self.performSegue(withIdentifier: "loggedIn", sender: self)
                }
            }
        }
    }
    
    @IBAction func createNewHomeClicked(_ sender: Any) {
    }
}

