//
//  Client.swift
//  OnTheMap
//
//  Created by Hiren Samtani on 18/05/18.
//  Copyright © 2018 Hiren Samtani. All rights reserved.
//

import UIKit

class Client : NSObject {
    
    var session = URLSession.shared
    
    // authentication state
    var sessionID: String? = nil
    var userKey = ""
    var userName = ""
    
    
    
    override init() {
        super.init()
    }
    
    //Single Instance
    class func shared() -> Client {
        struct Singleton {
            static var shared = Client()
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
        components.scheme = apiType == .udacity ? Constants.Udacity.APIScheme : Constants.Parse.APIScheme
        components.host = apiType == .udacity ? Constants.Udacity.APIHost : Constants.Parse.APIHost
        components.path = (apiType == .udacity ? Constants.Udacity.APIPath : Constants.Parse.APIPath) + (withPathExtension ?? "")
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        
        print("hbs url: ",components.url!)
        return components.url!
    }
    
    //Show activity indicator
    private func showActivityIndicator(_ show: Bool) {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = show
        }
    }
    
    func taskForGETMethod(
        _ method               : String,
        parameters             : [String:AnyObject],
        apiType                : APIType = .udacity,
        completionHandlerForGET: @escaping (_ result: Data?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        /* 2/3. Build the URL, Configure the request */
        let request = NSMutableURLRequest(url: buildURLFromParameters(parameters, withPathExtension: method, apiType: apiType))
        
        if apiType == .parse {
            request.addValue(Constants.ParseParametersValues.APIKey, forHTTPHeaderField: Constants.ParseParameterKeys.APIKey)
            request.addValue(Constants.ParseParametersValues.ApplicationID, forHTTPHeaderField: Constants.ParseParameterKeys.ApplicationID)
        }
        
        showActivityIndicator(true)
        
        /* 4. Make the request */
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                self.showActivityIndicator(false)
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
            
            self.showActivityIndicator(false)
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            completionHandlerForGET(newData, nil)
            
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
        completionHandlerForPOST : @escaping (_ result: Data?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        let request = NSMutableURLRequest(url: buildURLFromParameters(parameters, withPathExtension: method, apiType: apiType))
        
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonBody.data(using: String.Encoding.utf8)
        
        if let headersParam = requestHeaderParameters {
            for (key, value) in headersParam {
                request.addValue("\(value)", forHTTPHeaderField: key)
            }
        }
        
        showActivityIndicator(true)
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                self.showActivityIndicator(false)
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForPOST(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
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
            
            self.showActivityIndicator(false)
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            completionHandlerForPOST(newData, nil)
            
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
        completionHandlerForPUT  : @escaping (_ result: Data?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        let request = NSMutableURLRequest(url: buildURLFromParameters(parameters, withPathExtension: method, apiType: apiType))
        
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonBody.data(using: String.Encoding.utf8)
        
        if let headersParam = requestHeaderParameters {
            for (key, value) in headersParam {
                request.addValue("\(value)", forHTTPHeaderField: key)
            }
        }
        
        showActivityIndicator(true)
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                self.showActivityIndicator(false)
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
            
            self.showActivityIndicator(false)
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            
            completionHandlerForPUT(newData, nil)
            
        }
        task.resume()
        return task
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
    
    
    
    
    
    
}
