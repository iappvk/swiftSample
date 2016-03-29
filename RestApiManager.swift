//
//  RestApiManager.swift
//  devdactic-rest
//
//  Created by Simon Reimler on 16/03/15.
//  Copyright (c) 2015 Devdactic. All rights reserved.
//

import Foundation

typealias ServiceResponse = (JSON, NSError?) -> Void

class RestApiManager: NSObject {
    static let sharedInstance = RestApiManager()
    
    let baseURL = "http://api.randomuser.me/"
    
    func getRandomUser(onCompletion: (JSON) -> Void) {
        let route = baseURL
        makeHTTPGetRequest(route, onCompletion: { json, err in
            onCompletion(json as JSON)
        })
    }
    
    func postAPICall(url : String, parameter : String, onCompletion: (JSON) -> Void) {
        
        makeHTTPPostRequest(url, body : parameter, onCompletion: { json, err in
            onCompletion(json as JSON)
        })
    }
    
    func postAPICall1(url : String, parameter : AnyObject, onCompletion: (JSON) -> Void) {
        
        
        makeHTTPPostRequest1(url, body : parameter as! [String : AnyObject], onCompletion: { json, err in
            onCompletion(json as JSON)
        })
    }
    
    
    
}



func makeHTTPGetRequest(path: String, onCompletion: ServiceResponse) {
    let request = NSMutableURLRequest(URL: NSURL(string: path)!)
    
    let session = NSURLSession.sharedSession()
    
    let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
        let json:JSON = JSON(data: data!)
        
        print(" The Response")
        
        onCompletion(json, error)
    })
    task.resume()
}

//MARK: Perform a POST Request
func makeHTTPPostRequest(path: String, body: String, onCompletion: ServiceResponse) {
    
    var err: NSError?
    
    let request = NSMutableURLRequest(URL: NSURL(string: path)!)
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    // Set the method to POST
    request.HTTPMethod = "POST"
    
    request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding)
    
    let session = NSURLSession.sharedSession()
    
    let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
        if(data != nil){
            let json:JSON = JSON(data: data!)
            
            onCompletion(json, err)
        }else{
            print("API call Faild")
            IJProgressView.shared.hideProgressView()
        }
    })
    task.resume()
}

func makeHTTPPostRequest1(path: String, body: [String: AnyObject], onCompletion: ServiceResponse) {
    var err: NSError?
    let request = NSMutableURLRequest(URL: NSURL(string: path)!)
    
    // Set the method to POST
    request.HTTPMethod = "POST"
    
    // Set the POST body for the request
    
    do {
        request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(body, options: .PrettyPrinted)
        
        print(" The HTTPBody : \(request.HTTPBody)")
    } catch {
        //handle error. Probably return or mark function as throws
        
        print(" The parameter not passing ")
        print(error)
        IJProgressView.shared.hideProgressView()
        return
    }
    
    
    //    request.HTTPBody = NSJSONSerialization.dataWithJSONObject(body, options: nil, error: &err)
    let session = NSURLSession.sharedSession()
    
    let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
        
        if(data != nil){
            let json:JSON = JSON(data: data!)
            
            onCompletion(json, err)
        }else{
            print("API call Faild")
        }
    })
    task.resume()
}


/*

func callDeleteAPI(){
let id:NSString = NSUserDefaults.standardUserDefaults().stringForKey("ID")!

let obj : EventListObj = eventListArray[selectedIndex] as! EventListObj


var parameters = Dictionary<String, AnyObject>(minimumCapacity: 3)

parameters["action"] = "deleteEvent"
parameters["user_id"] = id
parameters["id"] = obj.event_id


RestApiManager.sharedInstance.postAPICall1("API URL", parameter: parameters) { (json : JSON) -> Void in
print("***** json : \(json)")
dispatch_async(dispatch_get_main_queue(), {

self.eventListArray.removeObjectAtIndex(self.selectedIndex)
self.tableView.reloadData()
})
}

}


*/
