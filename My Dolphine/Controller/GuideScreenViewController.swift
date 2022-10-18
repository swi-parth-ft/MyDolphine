//
//  GuideScreenViewController.swift
//  My Dolphine
//
//  Created by Parth Antala on 2022-10-05.
//

import UIKit

class GuideScreenViewController: UIViewController {

    @IBOutlet weak var continueButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        continueButton.setTitle("", for: .normal)
    }
    
    @IBAction func continueClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}
