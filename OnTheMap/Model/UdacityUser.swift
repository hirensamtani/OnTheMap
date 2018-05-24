//
//  User.swift
//  OnTheMap
//
//  Created by Hiren Samtani on 19/05/18.
//  Copyright © 2018 Hiren Samtani. All rights reserved.
//

import Foundation


struct ParseUserInfoKeys
{
    static let FirstName = "firstName"
    static let LastName = "lastName"
    static let Latitude = "latitude"
    static let Longitude = "longitude"
    static let MapString = "mapString"
    static let MediaURL = "mediaURL"
    static let ObjectID = "objectId"
    static let UniqueKey = "uniqueKey"
}
struct UdacityUser
{
    var firstName: String?
    var lastName: String?
    var latitude: Double?
    var longitude: Double?
    var mapString: String
    var mediaURL: String
    var objectID: String
    var uniqueKey: String
    
    
    
    var locationLabel: String {
        var name = ""
        if let firstName = firstName {
            name = firstName
        }
        if let lastName = lastName {
            if name.isEmpty {
                name = lastName
            } else {
                name += " \(lastName)"
            }
        }
        if name.isEmpty {
            name = "No name provided"
        }
        return name
    }
    
    
    init?(userInformation: [String:AnyObject])
    {
        guard let firstName = userInformation[ParseUserInfoKeys.FirstName] as? String else {
            return nil
        }
        self.firstName = firstName
        
        guard let lastName = userInformation[ParseUserInfoKeys.LastName] as? String else {
            return nil
        }
        self.lastName = lastName
        
        guard let latitude = userInformation[ParseUserInfoKeys.Latitude] as? Double else {
            return nil
        }
        self.latitude = latitude
        
        guard let longitude = userInformation[ParseUserInfoKeys.Longitude] as? Double else {
            return nil
        }
        self.longitude = longitude
        
        guard let mapString = userInformation[ParseUserInfoKeys.MapString] as? String else {
            return nil
        }
        self.mapString = mapString
        
        guard let mediaURL = userInformation[ParseUserInfoKeys.MediaURL] as? String else {
            return nil
        }
        self.mediaURL = mediaURL
        
        guard let objectID = userInformation[ParseUserInfoKeys.ObjectID] as? String else {
            return nil
        }
        self.objectID = objectID
        
        guard let uniqueKey = userInformation[ParseUserInfoKeys.UniqueKey] as? String else {
            return nil
        }
        self.uniqueKey = uniqueKey
        
    }
    
    
    func convertToDictionary() -> [String:AnyObject]
    {
        let userDictionary = [ParseUserInfoKeys.FirstName : firstName!,
                              ParseUserInfoKeys.LastName : lastName!,
                              ParseUserInfoKeys.Latitude : latitude!,
                              ParseUserInfoKeys.Longitude : longitude!,
                              ParseUserInfoKeys.MapString : mapString,
                              ParseUserInfoKeys.MediaURL : mediaURL,
                              ParseUserInfoKeys.ObjectID : objectID,
                              ParseUserInfoKeys.UniqueKey : uniqueKey
            ] as [String : Any]
        
        return userDictionary as [String : AnyObject]
    }
    
}
