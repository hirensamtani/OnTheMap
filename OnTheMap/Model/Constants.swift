//
//  Constants.swift
//  OnTheMap
//
//  Created by Hiren Samtani on 18/05/18.
//  Copyright © 2018 Hiren Samtani. All rights reserved.
//

import Foundation

struct Constants {
    struct HTTPHeaderField {
        static let accept = "Accept"
        static let contentType = "Content-Type"
    }
    
    struct HTTPHeaderFieldValue {
        static let json = "application/json"
    }
   
    
    struct Udacity {
        static let APIScheme = "https"
        static let APIHost = "www.udacity.com"
        static let APIPath = "/api"
    }
    
    struct UdacityMethods {
        static let Authentication = "/session"
        static let Users = "/users"
    }
    
    struct UdacityJSONResponseKeys {
        static let Account = "account"
        static let Registered = "registered"
        static let UserKey = "key"
        static let Session = "session"
        static let SessionID = "id"
    }
    
    
    
    
    
    struct Parse {
        static let APIScheme = "https"
        static let APIHost = "parse.udacity.com"
        static let APIPath = "/parse"
    }
    
    struct ParseMethods {
        static let StudentLocation = "/classes/StudentLocation"
    }
    
    struct ParseJSONResponseKeys {
        static let Results = "results"
    }
    
    struct ParseParameterKeys {
        static let APIKey = "X-Parse-REST-API-Key"
        static let ApplicationID = "X-Parse-Application-Id"
        static let Where = "where"
        static let Order = "order"
    }
    
    struct ParseParametersValues {
        static let APIKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let ApplicationID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
    }
}
