//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Hiren Samtani on 17/05/18.
//  Copyright © 2018 Hiren Samtani. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var textUserName: UITextField!
    @IBOutlet weak var textPassword: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    var activityIndicator: UIActivityIndicatorView? = nil
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textUserName.delegate = self
        textPassword.delegate = self
        
//        textUserName.text = "hirensamtani@gmail.com"
//        textPassword.text = "@harita1"
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textUserName.resignFirstResponder()
        textPassword.resignFirstResponder()
        
        if (textField == textUserName) {
            textPassword.becomeFirstResponder()
        } else if (textField == textPassword) {
            loginButton.sendActions(for: UIControlEvents.touchUpInside)
        }
        
        return true
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loginButton.setTitle("Login", for: [])
        loginButton.isEnabled = true
        
        
        if UdacityClientManager.sharedInstance.isLoggedIn() {
            UdacityClientManager.sharedInstance.logoutFromUdacity { (success, error) in
                guard(error == nil) else {
                    print(error!)
                    return;
                }
                print("Logged out successfully");
            }
            
        }
    }
    
    
    
    @IBAction func signUp(_ sender: Any) {
        
        if let signUpUrl = URL(string: "https://www.udacity.com/account/auth#!/signup") {
            UIApplication.shared.open(signUpUrl)
        }
        
    }
    
    
    @IBAction func login(_ sender: UIButton) {
        let username = textUserName.text
        let password = textPassword.text
        if username == "" || password == "" {
           
             self.showInfo(withTitle: "Error", withMessage: "Username or Password cannot be blank.")
            
            
            
            
//            let alertController = UIAlertController(title: "Error", message: "Username or Password cannot be blank.", preferredStyle: .alert)
//            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//            self.present(alertController, animated: true, completion: nil)
            
        } else {
            loginButton.setTitle("", for: [])
            sender.isEnabled = false
            activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
            
            activityIndicator?.center = CGPoint(x: sender.bounds.width / 2.0, y: sender.bounds.height / 2.0)
            
            sender.addSubview(activityIndicator!)
            activityIndicator!.startAnimating()
            
            UdacityClientManager.sharedInstance.authenticateWithUdacity(userName: username, password: password) { (success, error) in
                if success == true {
                    DispatchQueue.main.async {
//                        performUIUpdatesOnMain
                        self.activityIndicator!.stopAnimating()
                        self.performSegue(withIdentifier: "showMapsSegue", sender: self)
                        
                    }
                    
                } else {
                    print("\(error!)")
                
                    self.showInfo(withTitle: "Error", withMessage: error!.localizedDescription)
                    
                    DispatchQueue.main.async {
//                        let alertController = UIAlertController(title: "Error", message: error!.localizedDescription, preferredStyle: .alert)
//                        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//                        self.present(alertController, animated: true, completion: nil)
                        self.activityIndicator?.stopAnimating()
                        self.loginButton.isEnabled = true
                        self.loginButton.setTitle("Login", for: [])
                    }
                    
                    
                }
                
            }
        }
        
        
        
        
    }
    
    
    
}

