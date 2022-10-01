//
//  ViewController.swift
//  My Dolphine
//
//  Created by Parth Antala on 2022-09-30.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController {

    
    @IBOutlet weak var homeIDTextView: UITextField!
    @IBOutlet weak var passkeyTextView: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
     
    }

    @IBAction func loginButtonClicked(_ sender: Any) {
        if let id = homeIDTextView.text, let passkey = passkeyTextView.text {
            Auth.auth().signIn(withEmail: id, password: passkey) { authResult, error in
                if let e = error {
                    print(e)
                } else {
                    self.performSegue(withIdentifier: "toHomeView", sender: self)
                }
            }
        }
    }
    
    @IBAction func createNewHomeClicked(_ sender: Any) {
    }
}

