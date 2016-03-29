
//
//  RestApiManager.swift
//
//  Created by Vijayakumar on 05/06/15.
//  Copyright (c) 2015 Vijayakumar. All rights reserved.
//

import UIKit
import Alamofire
import Foundation
import SystemConfiguration



typealias ServiceResponse = (JSON, NSError?) -> Void


public class RestApiManager: NSObject {
    let  NETWORK_CONNECTION_FAILD = "Hot dang! Looks like you're not connected to the Net"
    
    public var STAGING : Bool = true
    public let DEVICE_LOG : Bool = true
    
    //    let baseURL="http://localhost:8090"  // Vijay's office imac ip
    
    
    static let sharedInstance = RestApiManager()
    
    // MARK: - API call for oAuth Login
    func loginAPI(parameter : AnyObject, onCompletion: (JSON) -> Void)
    {
        if Reachability.isConnectedToNetwork() == true
        {
            SwiftTryCatch.`try`({
                let url = self.baseURL+"/oauth/token"
                
                
                let str="Vijay:Vijay";
                
                let data : NSData = str.dataUsingEncoding(NSASCIIStringEncoding)!
                
                
                let base64Encoded = data.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
                
                //        var accessToken = ""
                
                let manager = Manager.sharedInstance
                
                manager.session.configuration.HTTPAdditionalHeaders = [
                    "Content-Type": "application/x-www-form-urlencoded",
                    //            "Accept": "application/vnd.lichess.v1+json",
                    "X-Requested-With": "XMLHttpRequest",
                    "Authorization": "Basic \(base64Encoded)"
                ]
                let headers = [
                    "Content-Type": "application/x-www-form-urlencoded",
                    //            "Accept": "application/vnd.lichess.v1+json",
                    "X-Requested-With": "XMLHttpRequest",
                    "Authorization": "Basic \(base64Encoded)"
                ]
                
                
                Alamofire.request(.POST, url, parameters: parameter as? [String : AnyObject], headers: headers)
                    .responseJSON { _, _, result in
                        switch (result) {
                        case .Success(let value):
                            print(value)
                            let responseObj=JSON(value)
                            onCompletion(responseObj)
                            
                        case .Failure(let data, let error):
                            if data != nil {
                                if let string = String(data: data!, encoding: NSUTF8StringEncoding) {
                                    print(string)
                                }
                            }
                            print(error)
                        }
                        
                }
                
                }, `catch`: { (error) in
                    print("\(error.description)", terminator: "")
                }, finally: {
                    // close resources
            })
        }else{
            RKDropdownAlert.title("Network Error", message: NETWORK_CONNECTION_FAILD)
        }
    }
    
    func callAPI(parameter : AnyObject, path : String, method : String, onCompletion: (JSON) -> Void){
        if Reachability.isConnectedToNetwork() == true
        {
            SwiftTryCatch.`try`({
                
                let url = self.baseURL + "/" + path
                
                var access_token = ""
                if((NSUserDefaults.standardUserDefaults().valueForKey("access_token")) != nil){
                    access_token = (NSUserDefaults.standardUserDefaults().valueForKey("access_token")) as! String
                }
                
                
                let manager = Manager.sharedInstance
                // Specifying the Headers we need
                manager.session.configuration.HTTPAdditionalHeaders = [
                    "Content-Type": "application/x-www-form-urlencoded",
                    "X-Requested-With": "XMLHttpRequest",
                    "Authorization": "Bearer \(access_token)"
                ]
                
                let headers = [
                    "Content-Type": "application/x-www-form-urlencoded",
                    "X-Requested-With": "XMLHttpRequest",
                    "Authorization": "Bearer \(access_token)"
                ]
                
                print(" The URL : \(url)", terminator: "")
                print(" The parameters : \(parameter)", terminator: "")
                
                
                Alamofire.request((method=="POST" ? .POST : .GET), url, parameters: parameter as? [String : AnyObject], headers: headers)
                    .responseJSON { _, _, result in
                        switch (result) {
                        case .Success(let value):
                            let responseObj=JSON(value)
                            print(" API Response :\(responseObj)")
                            onCompletion(responseObj)
                            
                        case .Failure(let data, let error):
                            if data != nil {
                                IJProgressView.shared.hideProgressView()
                                if let string = String(data: data!, encoding: NSUTF8StringEncoding) {
                                    print(" API Faild \(string)")
                                }
                            }
                            RKDropdownAlert.title("Network Error", message: "Unknow Error")
                            print(" Error 1\(error)")
                        }
                }
                }, `catch`: { (error) in
                    print("\(error.description)", terminator: "")
                }, finally: {
                    // close resources
            })
        }else
        {
            RKDropdownAlert.title("Network Error", message: NETWORK_CONNECTION_FAILD)
        }
    }
    
    func uploadImge(selectedImage : UIImageView,  parameter : AnyObject, path : String, method : String, onCompletion: (JSON) -> Void){
        
        SwiftTryCatch.`try`({
            /*
            var access_token = ""
            if((NSUserDefaults.standardUserDefaults().valueForKey("access_token")) != nil){
            access_token = (NSUserDefaults.standardUserDefaults().valueForKey("access_token")) as! String
            }
            
            let url = self.baseURL + "/" + path
            let request = NSMutableURLRequest(URL: NSURL(string:url)!)
            //        var session = NSURLSession.sharedSession()
            
            //        var imageData = UIImagePNGRepresentation(selectedImage.image!)
            
            request.HTTPMethod = "POST"
            
            request.setValue("Bearer \(access_token)", forHTTPHeaderField: "Authorization")
            let boundary = NSString(format: "---------------------------14737809831466499882746641449")
            let contentType = NSString(format: "multipart/form-data; boundary=%@",boundary)
            request.addValue(contentType as String, forHTTPHeaderField: "Content-Type")
            
            
            //        [request setValue:[NSString stringWithFormat:@"Bearer %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"]] forHTTPHeaderField:@"Authorization"];
            
            let body : NSData!
            
            
            
            body.appendData(NSString(format: "\r\n--%@\r\n",boundary).dataUsingEncoding(NSUTF8StringEncoding)!)
            body.appendData(NSString(format:"Content-Disposition: form-data; name=\"file\"; filename=\"sathish.jpg\"\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
            body.appendData(NSString(format:"Content-Type: application/octet-stream\r\n\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
            let imageData1: NSData = UIImageJPEGRepresentation(selectedImage.image!, 1.0)!
            
            
            
            body.appendData(imageData1)
            
            body.appendData(NSString(format: "\r\n--%@\r\n",boundary).dataUsingEncoding(NSUTF8StringEncoding)!)
            request.HTTPBody = body
            
            
            let returnData = try? NSURLConnection.sendSynchronousRequest(request, returningResponse: nil)
            
            let returnString = NSString(data: returnData!, encoding: NSUTF8StringEncoding)
            
            print("returnString \(returnString)")
            */
            }, `catch`: { (error) in
                print("\(error.description)", terminator: "")
            }, finally: {
                // close resources
        })
        /*
        println(" The URL : \(url)")
        
        
        var access_token = ""
        if((NSUserDefaults.standardUserDefaults().valueForKey("access_token")) != nil){
        access_token = (NSUserDefaults.standardUserDefaults().valueForKey("access_token")) as! String
        }
        
        var manager = Manager.sharedInstance
        // Specifying the Headers we need
        
        var boundary = "---------------------------14737809831466499882746641449"
        
        manager.session.configuration.HTTPAdditionalHeaders = ["Content-Type": "multipart/form-data;application/octet-stream;boundary=\(boundary)"]
        manager.session.configuration.HTTPAdditionalHeaders = ["Authorization": "Bearer \(access_token)"]
        //        manager.session.configuration.HTTPAdditionalHeaders = ["Content-Disposition": "form-data;name=\"file\";filename=\"vijay.jpg\""]
        
        
        
        //        manager.session.configuration.HTTPAdditionalHeaders = [
        //            "Content-Type": "multipart/form-data;application/octet-stream;boundary=\(boundary)",
        //            "X-Requested-With": "XMLHttpRequest",
        //            "Content-Disposition": "form-data; name=\"file\";filename=\"sathish.jpg\"\r\n",
        //            "Authorization": "Bearer \(access_token)"
        //        ]
        
        
        //        [body appendData:[@"Content-Disposition: form-data; name=\"file\"; filename=\"sathish.jpg\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        
        println(" The parameters : \(parameter)")
        
        //let imageData = UIImageJPEGRepresentation(selectedImage.image, 0.5)
        let imageData: NSData = UIImageJPEGRepresentation(selectedImage.image, 0.5)
        
        //        let data = UIImageJPEGRepresentation(image, 0.5)
        let encodedImage = imageData.base64En
        
        //let imageData: NSMutableData = NSMutableData.dataWithData(UIImageJPEGRepresentation(selectedImage.image, 30));
        
        
        //let imageData: NSMutableData = NSMutableData.dataWithData(UIImageJPEGRepresentation(selectedImage.image, 30));
        
        
        
        Alamofire.upload(.POST, url,  encodedImage)
        .progress { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
        println(totalBytesWritten)
        }
        .responseString { (request, response, JSON, error) in
        println(request)
        println(response)
        println(JSON)
        }
        
        */
        
        
        /*
        
        Alamofire.request((method=="POST" ? .POST : .GET), url, parameters: parameter as? [String : AnyObject])
        .responseJSON() {
        (_, _, responseData, error) in
        if let anError = error
        {
        // got an error in getting the data, need to handle it
        println("error calling POST on /posts")
        println(error)
        }
        else if let data: AnyObject = responseData
        {
        var responseObj=JSON(data)
        
        println(responseObj)
        
        
        onCompletion(responseObj)
        
        /*
        if(JSON(data)["success"]==true){
        
        
        var response = JSON(data)["result"]
        println(" The response : \(response)")
        onCompletion(response)
        
        
        }else{
        println("The API call Faild")
        }
        */
        
        
        
        }
        println(JSON)
        }
        
        */
    }
    // func loginAPI(parameter : AnyObject, onCompletion: (JSON) -> Void)
    func prayList(location : AnyObject, onCompletion: (JSON) -> Void){
        if Reachability.isConnectedToNetwork() == true
        {
            SwiftTryCatch.`try`({
                
                let escapedAddress : String = location.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
                
                let url = "http://muslimsalat.com/\(escapedAddress)/weekly.json?key=c65292cd907ac61c67acff0dfd801c97"
                
                print(" The url \(url)", terminator: "")
                
                var parameters = Dictionary<String, AnyObject>(minimumCapacity: 2)
                parameters["userId"] = (NSUserDefaults.standardUserDefaults().valueForKey("userId")) as! String
                
                
                
                var access_token = ""
                if((NSUserDefaults.standardUserDefaults().valueForKey("access_token")) != nil){
                    access_token = (NSUserDefaults.standardUserDefaults().valueForKey("access_token")) as! String
                }
                
                
                
                let headers = [
                    "Content-Type": "application/x-www-form-urlencoded",
                    "X-Requested-With": "XMLHttpRequest",
                    "Authorization": "Bearer \(access_token)"
                ]
                
                Alamofire.request(.POST, url, parameters: parameters , headers: headers)
                    .responseJSON { _, _, result in
                        switch (result) {
                        case .Success(let value):
                            let responseObj=JSON(value)
                            print(responseObj)
                            onCompletion(responseObj)
                            
                        case .Failure(let data, let error):
                            if data != nil {
                                if let string = String(data: data!, encoding: NSUTF8StringEncoding) {
                                    print(string)
                                }
                            }
                            print(error)
                        }
                        
                }
                }, `catch`: { (error) in
                    print("\(error.description)", terminator: "")
                }, finally: {
                    // close resources
            })
        }else
        {
            RKDropdownAlert.title("Network Error", message: NETWORK_CONNECTION_FAILD)
        }
        
    }
    
    
    func getGoogleNearByLocation(url : String, onCompletion: (JSON) -> Void)
    {
        
        if Reachability.isConnectedToNetwork() == true
        {
            SwiftTryCatch.`try`({
                print(" The url \(url)", terminator: "")
                
                var parameters = Dictionary<String, AnyObject>(minimumCapacity: 2)
                parameters["userId"] = (NSUserDefaults.standardUserDefaults().valueForKey("userId")) as! String
                
                
                var access_token = ""
                if((NSUserDefaults.standardUserDefaults().valueForKey("access_token")) != nil){
                    access_token = (NSUserDefaults.standardUserDefaults().valueForKey("access_token")) as! String
                }
                
                
                let headers = [
                    "Content-Type": "application/x-www-form-urlencoded",
                    "X-Requested-With": "XMLHttpRequest",
                    "Authorization": "Bearer \(access_token)"
                ]
                
                
                
                Alamofire.request(.POST, url, parameters: parameters , headers: headers)
                    .responseJSON { _, _, result in
                        switch (result) {
                        case .Success(let value):
                            let responseObj=JSON(value)
                            print(responseObj)
                            onCompletion(responseObj)
                            
                        case .Failure(let data, let error):
                            if data != nil {
                                if let string = String(data: data!, encoding: NSUTF8StringEncoding) {
                                    print(string)
                                }
                            }
                            print(error)
                        }
                        
                }
                
                
                /*
                Alamofire.request( .GET, url, parameters: parameters)
                .responseJSON() {
                (_, _, responseData, error) in
                if let anError = error
                {
                // got an error in getting the data, need to handle it
                print("error calling POST on /posts")
                print(error)
                }
                else if let data: AnyObject = responseData
                {
                
                var responseObj=JSON(data)
                print(responseObj)
                
                onCompletion(responseObj)
                //   NSNotificationCenter .defaultCenter().postNotificationName("", object: responseObj)
                
                }
                //        println(JSON)
                //
                }*/
                }, `catch`: { (error) in
                    print("\(error.description)", terminator: "")
                }, finally: {
                    // close resources
            })
        }else
        {
            RKDropdownAlert.title("Network Error", message: NETWORK_CONNECTION_FAILD)
        }
        
        
    }
    
    
}


/*
Call API

var parameters = Dictionary<String, AnyObject>(minimumCapacity: 2)

parameters["sourceUserId"] = (NSUserDefaults.standardUserDefaults().valueForKey("userId")) as! String
parameters["userId"] = (NSUserDefaults.standardUserDefaults().valueForKey("userId")) as! String

parameters["newsFeedId"] = (self.feedObj.newsFeedId != nil ? self.feedObj.newsFeedId :self.newsFeedID )


let path = "newsFeed/usersCommentList"

if(self.loadMore==true){
self.currentPage++;
//            self.newsFeedsArray.removeLastObject()

}

parameters["pageNumber"] = self.currentPage


RestApiManager.sharedInstance.callAPI(parameters, path: path, method: "POST", onCompletion: { json in

IJProgressView.shared.hideProgressView()

if(json["error"] != nil){
let alert = UIAlertView()

alert.title = "Faild!"
alert.message = json["error"]["message"].stringValue
alert.addButtonWithTitle("Ok")
alert.show()


}else{

print(" The result : \(json)", terminator: "")

var response = json["result"]["data"]


}



}


})


*/

