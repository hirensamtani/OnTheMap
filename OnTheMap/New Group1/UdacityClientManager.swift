//
//  UdacityClientManager.swift
//  OnTheMap
//
//  Created by Hiren Samtani on 19/05/18.
//  Copyright © 2018 Hiren Samtani. All rights reserved.
//

import UIKit


class UdacityClientManager: NSObject
{
    //MARK: Initilization
    static let sharedInstance = UdacityClientManager()
    
    var udacitySessionID: String?
    var udacityUserID: String?
    
    var session = URLSession.shared
    var userKey = ""
    
    
    override init()
    {
        super.init()
    }
    
    class func shared() -> UdacityClientManager {
        struct Singleton {
            static var shared = UdacityClientManager()
        }
        return Singleton.shared
    }
    
    enum APIType {
        case udacity
        case parse
    }
    
    // create a URL from parameters
    private func buildURLFromParameters(_ parameters: [String:AnyObject], withPathExtension: String? = nil, apiType: APIType = .udacity) -> URL {
        
        
        var components = URLComponents()
        components.scheme = apiType == .udacity ? Constants.ApiScheme : ParseConstants.ApiScheme
        components.host = apiType == .udacity ? Constants.ApiHost : ParseConstants.ApiHost
        components.path = (apiType == .udacity ? Constants.ApiPath : ParseConstants.ApiPath) + (withPathExtension ?? "")
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
//        print("hbs url ",components.url)
        
        return components.url!
    }
    
    // given raw JSON, return a usable Foundation object
    private func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(parsedResult, nil)
    }
    
    
    
    func taskForGETMethod(
        _ method               : String,
        parameters             : [String:AnyObject],
        apiType                : APIType = .udacity,
        completionHandlerForGET: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        /* 2/3. Build the URL, Configure the request */
        let request = NSMutableURLRequest(url: buildURLFromParameters(parameters, withPathExtension: method, apiType: apiType))
        
        if apiType == .parse {
            request.addValue(ParseApplicationValues.ParseRESTAPIKEY, forHTTPHeaderField: ParseApplicationKeys.ParseRESTAPIKey)
            request.addValue(ParseApplicationValues.ParseApplicationID, forHTTPHeaderField: ParseApplicationKeys.ParseApplicationID)
        }
        
        
        
        /* 4. Make the request */
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForGET(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error!.localizedDescription)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            // skipping the first 5 characters for Udacity API calls
            var newData = data
            if apiType == .udacity {
                let range = Range(5..<data.count)
                newData = data.subdata(in: range)
            }
            
           
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerForGET)
            
            //completionHandlerForGET(newData, nil)
            
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    // MARK: - POST
    
    func taskForPOSTMethod(
        _ method                 : String,
        parameters               : [String:AnyObject],
        requestHeaderParameters  : [String:AnyObject]? = nil,
        jsonBody                 : String,
        apiType                  : APIType = .udacity,
        completionHandlerForPOST : @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        print(jsonBody," ",apiType)
        
        let request = NSMutableURLRequest(url: buildURLFromParameters(parameters, withPathExtension: method, apiType: apiType))
        
        
        if apiType == .parse {
            request.addValue(ParseApplicationValues.ParseRESTAPIKEY, forHTTPHeaderField: ParseApplicationKeys.ParseRESTAPIKey)
            request.addValue(ParseApplicationValues.ParseApplicationID, forHTTPHeaderField: ParseApplicationKeys.ParseApplicationID)
        }
        
        
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonBody.data(using: String.Encoding.utf8)
        
        if let headersParam = requestHeaderParameters {
            for (key, value) in headersParam {
                request.addValue("\(value)", forHTTPHeaderField: key)
            }
        }
        
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForPOST(nil, NSError(domain: "taskForPOSTMethod", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error!.localizedDescription)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                sendError("Request did not return a valid response.")
                return
            }
            
            switch (statusCode) {
            case 403:
                sendError("Please check your credentials and try again.")
            case 200 ..< 299:
                break
            default:
                sendError("Your request returned a status code other than 2xx!")
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            // skipping the first 5 characters for Udacity API calls
            var newData = data
            if apiType == .udacity {
                let range = Range(5..<data.count)
                newData = data.subdata(in: range)
            }
            
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerForPOST)
            
            
           // completionHandlerForPOST(newData, nil)
            
        }
        task.resume()
        
        return task
    }


// MARK: - DELETE

func taskForDeleteMethod(
    _ method                   : String,
    parameters                 : [String:AnyObject],
    apiType                    : APIType = .udacity,
    completionHandlerForDELETE : @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
    
    let request = NSMutableURLRequest(url: buildURLFromParameters(parameters, withPathExtension: method, apiType: apiType))
    
    
    if apiType == .parse {
        request.addValue(ParseApplicationValues.ParseRESTAPIKEY, forHTTPHeaderField: ParseApplicationKeys.ParseRESTAPIKey)
        request.addValue(ParseApplicationValues.ParseApplicationID, forHTTPHeaderField: ParseApplicationKeys.ParseApplicationID)
    }
    
    
    request.httpMethod = "DELETE"
    
    var xsrfCookie: HTTPCookie? = nil
    let sharedCookieStorage = HTTPCookieStorage.shared
    
    for cookie in sharedCookieStorage.cookies! {
        if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
    }
    if let xsrfCookie = xsrfCookie {
        request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
    }
    
    
    let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
        
        func sendError(_ error: String) {
           
            print(error)
            let userInfo = [NSLocalizedDescriptionKey : error]
            completionHandlerForDELETE(nil, NSError(domain: "taskForDeleteMethod", code: 1, userInfo: userInfo))
        }
        
        /* GUARD: Was there an error? */
        guard (error == nil) else {
            sendError("There was an error with your request: \(error!.localizedDescription)")
            return
        }
        
        /* GUARD: Did we get a successful 2XX response? */
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
            sendError("Request did not return a valid response.")
            return
        }
        
        switch (statusCode) {
        case 403:
            sendError("Please check your credentials and try again.")
        case 200 ..< 299:
            break
        default:
            sendError("Your request returned a status code other than 2xx!")
        }
        
        /* GUARD: Was there any data returned? */
        guard let data = data else {
            sendError("No data was returned by the request!")
            return
        }
        
        // skipping the first 5 characters for Udacity API calls
        var newData = data
        if apiType == .udacity {
            let range = Range(5..<data.count)
            newData = data.subdata(in: range)
        }
        
        
        
        /* 5/6. Parse the data and use the data (happens in completion handler) */
        self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerForDELETE)
        
    }
    task.resume()
    return task
}




func taskForPUTMethod(
    _ method                 : String,
    parameters               : [String:AnyObject],
    requestHeaderParameters  : [String:AnyObject]? = nil,
    jsonBody                 : String,
    apiType                  : APIType = .udacity,
    completionHandlerForPUT  : @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
    
    let request = NSMutableURLRequest(url: buildURLFromParameters(parameters, withPathExtension: method, apiType: apiType))
    
    
    if apiType == .parse {
        request.addValue(ParseApplicationValues.ParseRESTAPIKEY, forHTTPHeaderField: ParseApplicationKeys.ParseRESTAPIKey)
        request.addValue(ParseApplicationValues.ParseApplicationID, forHTTPHeaderField: ParseApplicationKeys.ParseApplicationID)
    }
    
    request.httpMethod = "PUT"
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = jsonBody.data(using: String.Encoding.utf8)
    
    if let headersParam = requestHeaderParameters {
        for (key, value) in headersParam {
            request.addValue("\(value)", forHTTPHeaderField: key)
        }
    }
    
    
    
    let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
        
        func sendError(_ error: String) {
            
            print(error)
            let userInfo = [NSLocalizedDescriptionKey : error]
            completionHandlerForPUT(nil, NSError(domain: "taskForPUTMethod", code: 1, userInfo: userInfo))
        }
        
        /* GUARD: Was there an error? */
        guard (error == nil) else {
            sendError("There was an error with your request: \(error!.localizedDescription)")
            return
        }
        
        /* GUARD: Did we get a successful 2XX response? */
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
            sendError("Request did not return a valid response.")
            return
        }
        
        switch (statusCode) {
        case 403:
            sendError("Please check your credentials and try again.")
        case 200 ..< 299:
            break
        default:
            sendError("Your request returned a status code other than 2xx!")
        }
        
        /* GUARD: Was there any data returned? */
        guard let data = data else {
            sendError("No data was returned by the request!")
            return
        }
        
        // skipping the first 5 characters for Udacity API calls
        var newData = data
        if apiType == .udacity {
            let range = Range(5..<data.count)
            newData = data.subdata(in: range)
        }
        
       
        
        /* 5/6. Parse the data and use the data (happens in completion handler) */
        self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerForPUT)
        
    }
    task.resume()
    return task
}




}







