//
//  UdacityUsersModel.swift
//  OnTheMap
//
//  Created by Hiren Samtani on 19/05/18.
//  Copyright © 2018 Hiren Samtani. All rights reserved.
//

import Foundation

class UdacityUsersModel: NSObject
{
    
    static let sharedInstance = UdacityUsersModel()
    
    var udacityUsers: [UdacityUser] = [UdacityUser]()
    
    func loadUsersData(completionHandlerForLoadUsersData:@escaping (_ success: Bool, _ error: NSError?) -> Void) -> Void
    {
        udacityUsers.removeAll()
        UdacityClientManager.sharedInstance.getStudentsInformationFromParse { (usersInfoArray, error) in
            
            guard (error == nil) else {
                completionHandlerForLoadUsersData(false, error!)
                return
            }
            
            guard (usersInfoArray != nil) else {
                completionHandlerForLoadUsersData(false, NSError(domain: "CompletionHandlerForLoadUsrsData", code: 1, userInfo: [NSLocalizedDescriptionKey : "Error getting parse users info"]))
                return
            }
            for user in usersInfoArray! {
                guard let udacityUser = UdacityUser(userInformation: user) else {
                    continue
                }
                
                self.udacityUsers.append(udacityUser)
            }
            completionHandlerForLoadUsersData(true, nil)
        }
    }
    
    func getUserForIndex(index: Int) -> UdacityUser?
    {
        if index >= 0 && index < udacityUsers.count {
            return udacityUsers[index]
        }
        
        return nil
    }
    
    func getUsersCount() -> Int
    {
        return udacityUsers.count
    }
    
    
}
