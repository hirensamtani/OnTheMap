//
//  ClientProjExtension.swift
//  OnTheMap
//
//  Created by Hiren Samtani on 19/05/18.
//  Copyright © 2018 Hiren Samtani. All rights reserved.
//

import Foundation

extension Client {
    
    func authenticateWith(userEmail: String, andPassword: String, completionHandlerForAuthentication: @escaping (_ success: Bool, _ error: NSError?) -> Void) {
        let jsonBody = "{\"udacity\": {\"username\": \"\(userEmail)\", \"password\": \"\(andPassword)\"}}"
        _ = taskForPOSTMethod(Constants.UdacityMethods.Authentication, parameters: [:], jsonBody: jsonBody, completionHandlerForPOST: { (data, error) in
            
            func sendError(error: NSError?) {
                completionHandlerForAuthentication(false, error)
            }
            
            guard (error == nil) else
            {
                sendError(error: error)
                return
            }
            
            guard let udacitySession = results[JSONResponseKeys.Session] as? [String:AnyObject]  else
            {
                let userInfo = [NSLocalizedDescriptionKey : "Cannot find session key in results '\(results)"]
                sendError(NSError(domain: "authenticateWithUdacity", code: 1, userInfo: userInfo))
                return
            }
            
            guard let udacitySessionID = udacitySession[JSONResponseKeys.ID] as? String else {
                let userInfo = [NSLocalizedDescriptionKey : "Cannot find ID key in results '\(results)"]
                sendError(NSError(domain: "authenticateWithUdacity", code: 1, userInfo: userInfo))
                return
            }
            
            guard let udacityAccount = results[JSONResponseKeys.Account] as? [String : AnyObject] else {
                let userInfo = [NSLocalizedDescriptionKey : "Cannot find Udacity Account key in results '\(results)"]
                sendError(NSError(domain: "authenticateWithUdacity", code: 1, userInfo: userInfo))
                return
            }
            
            guard let udacityKey = udacityAccount[JSONResponseKeys.Key] as? String else {
                let userInfo = [NSLocalizedDescriptionKey : "Cannot find Udacity key (ID) in results '\(results)"]
                sendError(NSError(domain: "authenticateWithUdacity", code: 1, userInfo: userInfo))
                return
            }
            
            self.udacityUserID = udacityKey
            self.udacitySessionID = udacitySessionID
            
            completionHandlerForAuthentication(success: true, error: nil)
            
            
        })
    }
    
//    func parseUserSession(data: Data?) -> (UserSession?, NSError?) {
//        var studensLocation: (userSession: UserSession?, error: NSError?) = (nil, nil)
//        do {
//            if let data = data {
//                let jsonDecoder = JSONDecoder()
//                studensLocation.userSession = try jsonDecoder.decode(UserSession.self, from: data)
//            }
//        } catch {
//            print("Could not parse the data as JSON: \(error.localizedDescription)")
//            let userInfo = [NSLocalizedDescriptionKey : error]
//            studensLocation.error = NSError(domain: "parseUserSession", code: 1, userInfo: userInfo)
//        }
//        return studensLocation
//    }
    
    
}
