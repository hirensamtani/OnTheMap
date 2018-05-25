//
//  UserMapBaseViewController.swift
//  OnTheMap
//
//  Created by Hiren Samtani on 22/05/18.
//  Copyright © 2018 Hiren Samtani. All rights reserved.
//

import UIKit


class UserMapBaseViewController : UITabBarController {
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func refresh(_ sender: Any) {
//        print("hbs key1 ", UdacityClientManager.sharedInstance.userKey)

        if self.selectedViewController is  UsersMapViewController
        {
            let selViewMap =  selectedViewController as! UsersMapViewController
            selViewMap.refreshData()
            
        }
        else if self.selectedViewController is UsersListViewController
        {
            let selViewMap =  selectedViewController as! UsersListViewController
            selViewMap.refreshData()
        }
    
    }
    
    @IBAction func unwindToVC1(segue:UIStoryboardSegue) {
        self.refresh(segue)
    }
    
    
    
    @IBAction func logout(_ sender: Any) {
        
        if UdacityClientManager.sharedInstance.isLoggedIn() {
            UdacityClientManager.sharedInstance.logoutFromUdacity { (success, error) in
                guard(error == nil) else {
                    print(error!)
                    return;
                }
                print("Logged out successfully");
            }
            
            showInfo(withTitle: "Log Out", withMessage: "Logged out successfully!", action: {
                self.dismiss(animated: true, completion: nil)
            })
            
            
        }
       
    }

    
    
}
