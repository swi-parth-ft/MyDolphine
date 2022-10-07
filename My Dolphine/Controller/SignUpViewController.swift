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
    @IBOutlet weak var loginButton: UIButton!
    
    var user: User!
    let ref = Database.database().reference(withPath: "items")
    let ref1 = Database.database().reference(withPath: "categories")
    let usersRef = Database.database().reference(withPath: "online")
    
    var refObservers: [DatabaseHandle] = []
    var handle: AuthStateDidChangeListenerHandle?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.setTitle("", for: .normal)
        passkeyTextView.isSecureTextEntry = true
        // Do any additional setup after loading the view.
        Auth.auth().addStateDidChangeListener { auth, user in
            //MARK: - Listen for online users, set currently logged in user
            guard let user = user else { return }
            self.user = User(authData: user)
        
            let currentUserRef = self.usersRef.child(self.user.uid)
            currentUserRef.setValue(self.user.email)
            currentUserRef.onDisconnectRemoveValue()
        }
    }
    
    @IBAction func loginButtonClicked(_ sender: Any) {
        if let id = homeIdTextView.text, let passkey = passkeyTextView.text {
            Auth.auth().createUser(withEmail: id, password: passkey) { authResult, error in
                if let e = error {
                    print(e)
                } else {
            
                            let category = Category(category: "General", emoji: "🏡", cardNumber: 6, counter: 0, addedByUser: self.user.uid)
                            
                            //MARK: - Ref to snapshot of grocery list
                            let categoryRef = self.ref1.child("General".lowercased())
                            
                            categoryRef.setValue(category.toAnyObject())
                       
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
