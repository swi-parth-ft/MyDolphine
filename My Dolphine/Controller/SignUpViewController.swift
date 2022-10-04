//
//  SignUpViewController.swift
//  My Dolphine
//
//  Created by Parth Antala on 2022-10-01.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {

    @IBOutlet weak var passkeyTextView: UITextField!
    @IBOutlet weak var homeIdTextView: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passkeyTextView.isSecureTextEntry = true
        // Do any additional setup after loading the view.
    }
    
    @IBAction func loginButtonClicked(_ sender: Any) {
        if let id = homeIdTextView.text, let passkey = passkeyTextView.text {
            Auth.auth().createUser(withEmail: id, password: passkey) { authResult, error in
                if let e = error {
                    print(e)
                } else {
                    //Navigate to the ChatViewController
                    self.performSegue(withIdentifier: "toHomeView", sender: self)
                }
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
