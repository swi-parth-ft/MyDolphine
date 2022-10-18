//
//  SettingsViewController.swift
//  My Dolphine
//
//  Created by Parth Antala on 2022-10-06.
//

import UIKit

import StoreKit

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var selectedRow = 0
    var modes = ["dark","light","Auto"]
    
    @IBOutlet weak var themeLabel: UILabel!
    @IBOutlet weak var grayTheme: UIButton!
    @IBOutlet weak var blackTheme: UIButton!
    @IBOutlet weak var shareApp: UIButton!
    @IBOutlet weak var tableView: UITableView!

    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        grayTheme.setTitle("", for: .normal)
        blackTheme.setTitle("", for: .normal)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.backgroundColor = UIColor.systemGray6
        tableView.layer.cornerRadius=10
        tableView.layer.backgroundColor = UIColor.systemGray3.cgColor
        
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
            blackTheme.setImage(UIImage(named: "blackThemeSelected"), for: .normal)
            grayTheme.setImage(UIImage(named: "grayTheme"), for: .normal)
        } else {
            view.backgroundColor = .systemGray6
            blackTheme.setImage(UIImage(named: "blackTheme"), for: .normal)
            grayTheme.setImage(UIImage(named: "grayThemeSelected"), for: .normal)
        }
        
        let window = UIApplication.shared.keyWindow
        if window?.overrideUserInterfaceStyle == .dark {
            showTheme()
        } else {
            hideTheme()
        }
        
    }
    
    //MARK: - viewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        tableView.frame = CGRect(x: tableView.frame.origin.x, y: tableView.frame.origin.y, width: tableView.frame.size.width, height: tableView.contentSize.height)
    }
    
    
    override func viewDidLayoutSubviews(){
        tableView.frame = CGRect(x: tableView.frame.origin.x, y: tableView.frame.origin.y, width: tableView.frame.size.width, height: tableView.contentSize.height)
        tableView.reloadData()
    }
    
    //MARK: - theme Selected
    @IBAction func blackThemeSelected(_ sender: Any) {
        UserDefaults.standard.set(1, forKey: "theme")
        blackTheme.setImage(UIImage(named: "blackThemeSelected"), for: .normal)
        grayTheme.setImage(UIImage(named: "grayTheme"), for: .normal)
        view.backgroundColor = .black
    }
    
    @IBAction func grayThemeSelected(_ sender: Any) {
        UserDefaults.standard.set(2, forKey: "theme")
        grayTheme.setImage(UIImage(named: "grayThemeSelected"), for: .normal)
        blackTheme.setImage(UIImage(named: "blackTheme"), for: .normal)
        view.backgroundColor = .systemGray6
    }
    
    //MARK: - rate app
    @IBAction func rateApp(_ sender: Any) {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
            
        } else if let url = URL(string: "ttps://apps.apple.com/us/app/My-Dolphin/id6443741503") {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    //MARK: - show hide theme
    func hideTheme(){
        UIView.transition(with: themeLabel, duration: 0.4,
                          options: .transitionCrossDissolve,
                          animations: {
            self.themeLabel.isHidden = true
            self.blackTheme.isHidden = true
            self.grayTheme.isHidden = true
        })
    }
    
    func showTheme(){
        UIView.transition(with: themeLabel, duration: 0.4,
                          options: .transitionCrossDissolve,
                          animations: {
            self.themeLabel.isHidden = false
            self.blackTheme.isHidden = false
            self.grayTheme.isHidden = false
            
        })
    }
    
    //MARK: - share app
    @IBAction func shareAppClicked(_ sender: Any) {
        let vc = UIActivityViewController(activityItems: ["Check my app at https://apps.apple.com/us/app/My-Dolphin/id6443741503"], applicationActivities: nil)
        vc.popoverPresentationController?.sourceView = self.view
        
        self.present(vc, animated: true, completion: nil)
    }
    
    //MARK: - tableView
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
        
        selectedRow = indexPath.row
        for cell in tableView.visibleCells {
            cell.accessoryType = .none
        }
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        
        if modes[indexPath.row] == "dark" {
            let window = UIApplication.shared.keyWindow
            window?.overrideUserInterfaceStyle = .dark
            UserDefaults.standard.set(1, forKey: "apperence")
            
            showTheme()
            self.navigationController?.navigationBar.tintColor = UIColor.white
        }
        
        else if modes[indexPath.row] == "light" {
            let window = UIApplication.shared.keyWindow
            window?.overrideUserInterfaceStyle = .light
            UserDefaults.standard.set(2, forKey: "apperence")
            
            hideTheme()
            self.navigationController?.navigationBar.tintColor = UIColor.black
        }
        
        else {
            let window = UIApplication.shared.keyWindow
            window?.overrideUserInterfaceStyle = .unspecified
            UserDefaults.standard.set(0, forKey: "apperence")
            
            if window?.overrideUserInterfaceStyle == .dark {
                showTheme()
                self.navigationController?.navigationBar.tintColor = UIColor.white
            } else {
                hideTheme()
                self.navigationController?.navigationBar.tintColor = UIColor.black
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.accessoryType = indexPath.row == selectedRow ? .checkmark : .none
    }
}

