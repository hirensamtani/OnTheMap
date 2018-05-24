//
//  UdacityClientManagerConvenience.swift
//  OnTheMap
//
//  Created by Hiren Samtani on 20/05/18.
//  Copyright © 2018 Hiren Samtani. All rights reserved.
//
import UIKit


extension UdacityClientManager {
    
    
    func isLoggedIn() -> Bool
    {
        return udacitySessionID != nil && udacityUserID != nil
    }
    
    func logoutFromUdacity(completionHanlderForLogout: @escaping (_ success: Bool?, _ error: NSError?) -> Void) -> Void
    {
        taskForDeleteMethod(Methods.Session, parameters: [:]) { (result, error) in
            guard(error == nil) else {
                completionHanlderForLogout(false, error)
                return
            }
        
            self.udacityUserID = nil;
            self.udacitySessionID = nil;
            completionHanlderForLogout(true, nil);
        }
    }
    
    func authenticateWithUdacity(userName: String?, password: String?, completionHandlerForAuthentication: @escaping (_ success: Bool?,_ error: NSError?) -> Void) -> Void {

        let jsonBody = "{\"\(BodyKeys.Udacity)\": {\"\(BodyKeys.Username)\": \"\(userName!)\", \"\(BodyKeys.Password)\": \"\(password!)\"}}"

            
            
            taskForPOSTMethod(Methods.Session, parameters: [:], jsonBody: jsonBody, completionHandlerForPOST: { (results, error) in

                func sendError(_ error: NSError?) {
                    completionHandlerForAuthentication(false, error)
                }

                guard (error == nil) else
                {
                    sendError(error)
                    return
                }

                guard let udacitySession = results![JSONResponseKeys.Session] as? [String:AnyObject]  else
                {
                    let userInfo = [NSLocalizedDescriptionKey : "Cannot find session key in results '\(results!)"]
                    sendError(NSError(domain: "authenticateWithUdacity", code: 1, userInfo: userInfo))
                    return
                }

                guard let udacitySessionID = udacitySession[JSONResponseKeys.ID] as? String else {
                    let userInfo = [NSLocalizedDescriptionKey : "Cannot find ID key in results '\(results!)"]
                    sendError(NSError(domain: "authenticateWithUdacity", code: 1, userInfo: userInfo))
                    return
                }

                guard let udacityAccount = results![JSONResponseKeys.Account] as? [String : AnyObject] else {
                    let userInfo = [NSLocalizedDescriptionKey : "Cannot find Udacity Account key in results '\(results!)"]
                    sendError(NSError(domain: "authenticateWithUdacity", code: 1, userInfo: userInfo))
                    return
                }

                guard let udacityKey = udacityAccount[JSONResponseKeys.Key] as? String else {
                    let userInfo = [NSLocalizedDescriptionKey : "Cannot find Udacity key (ID) in results '\(results!)"]
                    sendError(NSError(domain: "authenticateWithUdacity", code: 1, userInfo: userInfo))
                    return
                }

                
//                print("hbs key: ",udacityKey)
                self.udacityUserID = udacityKey
                self.udacitySessionID = udacitySessionID

                completionHandlerForAuthentication(true, nil)
            })
    }
    
    //MARK: Getting Data From Parse
    
    func getStudentsInformationFromParse(completionHandlerForGetStudentDataFromParse: @escaping (_ usersInfoArray: [[String:AnyObject]]?, _ error: NSError?) -> Void) -> Void
    {
        let parameters = [ ParseParameterKeys.SortOrder : ParseParameterValues.SortDescending]
        
        taskForGETMethod(ParseMethods.StudentLocation, parameters: parameters as [String : AnyObject], apiType: .parse ,completionHandlerForGET: { (results, error) in
            
            guard (error == nil) else {
                completionHandlerForGetStudentDataFromParse(nil, error)
                return
            }
            
            
            guard let resultsUsersInfo = results![ParseResults.ParseResults] as? [[String:AnyObject]]  else
            {
                let userInfo = [NSLocalizedDescriptionKey : "Cannot find results key in  '\(results!)"]
                completionHandlerForGetStudentDataFromParse(nil, (NSError(domain: "getStudentsInformationFromParse", code: 1, userInfo: userInfo)))
                return
            }
            
            completionHandlerForGetStudentDataFromParse(resultsUsersInfo, nil)
            
        })
    }
    
    
//Single Student info
    func getStudentLocationFromParse(completionHandlerForGetStudentLocation: @escaping (_ studentInfo: [String:AnyObject]? , _ studentFound: Bool, _ error: NSError?) -> Void) -> Void
    {
        if udacityUserID == nil {
            completionHandlerForGetStudentLocation(nil, false, NSError(domain: "getStudentLocationFromParse", code: 1, userInfo: [NSLocalizedDescriptionKey : "User Is Not Logged In"]))
        } else {
            let parameters = [ ParseParameterKeys.Where : "{\"uniqueKey\":\"\(udacityUserID!)\"}"]
            taskForGETMethod(ParseMethods.StudentLocation, parameters: parameters as [String : AnyObject], apiType : APIType.parse) { (result, error) in
               
                
                guard (error == nil) else {
                    completionHandlerForGetStudentLocation(nil, false, error)
                    return
                }
                
                guard let resultUserInfo = result![ParseResults.ParseResults] as? [[String:AnyObject]] else {
                    let userInfo = [NSLocalizedDescriptionKey : "Coulnd't find results key in '\(result!)"]
                    completionHandlerForGetStudentLocation(nil, false, NSError(domain: "getStudentLocationFromParse", code: 1, userInfo: userInfo))
                    return
                }
                guard resultUserInfo.count > 0 else {
                    completionHandlerForGetStudentLocation(nil, false, nil)
                    return
                    
                }
                completionHandlerForGetStudentLocation(resultUserInfo[0], true, nil)
            }
        }
        
    }
    
    func postSudentLocationToParse(info: UdacityUser, completionHandlerForPostStudentLocationToParse: @escaping (_ success: Bool, _ error: NSError?) -> Void) -> Void

    {
        
        let jsonBody = "{\"uniqueKey\": \"\(info.uniqueKey)\", \"firstName\": \"\(info.firstName!)\", \"lastName\": \"\(info.lastName!)\",\"mapString\": \"\(info.mapString)\", \"mediaURL\": \"\(info.mediaURL)\",\"latitude\": \(info.latitude!), \"longitude\": \(info.longitude!)}"
        

            taskForPOSTMethod(ParseMethods.StudentLocation, parameters: [:], jsonBody: jsonBody, apiType : APIType.parse, completionHandlerForPOST: { (results, error) in
                guard (error == nil) else {
                    completionHandlerForPostStudentLocationToParse(false, error)
                    return
                }

                completionHandlerForPostStudentLocationToParse(true, nil)
            })
    }
    
    
    func updateStudentLocationToParse(info: UdacityUser, completionHandlerForUpdateSudentLocationToParse: @escaping (_ success: Bool, _ error: NSError?) -> Void) -> Void
        {
             let jsonBody = "{\"uniqueKey\": \"\(info.uniqueKey)\", \"firstName\": \"\(info.firstName!)\", \"lastName\": \"\(info.lastName!)\",\"mapString\": \"\(info.mapString)\", \"mediaURL\": \"\(info.mediaURL)\",\"latitude\": \(info.latitude!), \"longitude\": \(info.longitude!)}"
            
            taskForPUTMethod(self.subtituteKeyInMethod(method: ParseMethods.StudentLocationWithObjectID, key: "1", value: (info.objectID))!, parameters: [:], jsonBody: jsonBody, apiType : APIType.parse ,completionHandlerForPUT: { (result, error) in
                                    guard (error == nil) else {
                                        completionHandlerForUpdateSudentLocationToParse(false, error)
                                        return
                                    }
                    completionHandlerForUpdateSudentLocationToParse(true, nil)
                                })
            
    }
    
    
    private func subtituteKeyInMethod(method: String, key: String, value: String) -> String? {
        if method.range(of: "{\(key)}") != nil {
            return method.replacingOccurrences(of: "{\(key)}", with: value)
        } else {
            return nil
        }
    }
    
    
    
}
