//
//  UsersListViewController.swift
//  OnTheMap
//
//  Created by Hiren Samtani on 21/05/18.
//  Copyright © 2018 Hiren Samtani. All rights reserved.
//

import UIKit

class UsersListViewController : UIViewController, UITableViewDelegate, UITableViewDataSource
    
{
    
    
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        refreshData()
    }
    
    func refreshData()
    {
        
        self.showActivityIndicator(self.activityIndicator)
        UdacityUsersModel.sharedInstance.loadUsersData { (success, error) in
            
            guard (error == nil) else {
                self.showInfo(withTitle: "Error", withMessage: error!.localizedDescription)
                return
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
             self.hideActivityIndicator(self.activityIndicator)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UdacityUsersModel.sharedInstance.getUsersCount()

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: "userInfoCell", for: indexPath)
        let udacityUser = UdacityUsersModel.sharedInstance.getUserForIndex(index: indexPath.row)
        cell.textLabel?.text = "\(udacityUser!.firstName!) \(udacityUser!.lastName!)"
        cell.detailTextLabel?.text = udacityUser?.mediaURL
        cell.imageView?.image = #imageLiteral(resourceName: "icon_pin")
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let udacityUser = UdacityUsersModel.sharedInstance.getUserForIndex(index: indexPath.row)

        openWithSafari(udacityUser!.mediaURL)
    }
    
    
    
    
    
    
}
