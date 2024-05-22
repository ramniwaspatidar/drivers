
import Foundation
import SVProgressHUD
import JWTDecode
import FirebaseAuth
import FirebaseMessaging

class NetworkManager {
    static var shared  = NetworkManager()
    
    private init(){}
    
    
    // post Request
    public func postRequest(_ url : URL,_ hude : Bool,_ loadingText : String, params : [String : Any], networkHandler:@escaping ((_ responce : [String : Any], _ statusCode : Int) -> Void)){
        if !ReachabilityTest.isConnectedToNetwork() {
            return
        }
        if(hude){
            DispatchQueue.main.async {
                SVProgressHUD.show()
                SVProgressHUD.setDefaultMaskType(.clear)
            }
        }
        
        self.callRequest(url, hude, loadingText, method: "POST", params: params) { responce, statusCode in
            networkHandler(responce,statusCode)
        }
    }
    
    public func putRequest(_ url : URL,_ hude : Bool,_ loadingText : String, params : [String : Any], networkHandler:@escaping ((_ responce : [String : Any], _ statusCode : Int) -> Void)){
        if !ReachabilityTest.isConnectedToNetwork() {
            return
        }
        if(hude){
            DispatchQueue.main.async {
                SVProgressHUD.show()
                SVProgressHUD.setDefaultMaskType(.clear)
            }
        }
        
        self.callRequest(url, hude, loadingText, method: "PUT", params: params) { responce, statusCode in
            networkHandler(responce,statusCode)
        }
    }
    
    
    // get Request
    public func getRequest(_ url : URL,_ hude : Bool,_ loadingText : String, networkHandler:@escaping ((_ responce : [String : Any], _ statusCode : Int) -> Void)){
        
        if !ReachabilityTest.isConnectedToNetwork() {
            return
        }
        
        if(hude){
            DispatchQueue.main.async {
                SVProgressHUD.show()
                SVProgressHUD.setDefaultMaskType(.clear)
            }
        }
        
        self.callRequest(url, hude, loadingText, method: "GET", params: [String : Any]()) { responce, statusCode in
            networkHandler(responce,statusCode)
        }
    }
    
    
    public func deleteRequest(_ url : URL,_ hude : Bool,_ loadingText : String, networkHandler:@escaping ((_ responce : [String : Any], _ statusCode : Int) -> Void)){
        
        if !ReachabilityTest.isConnectedToNetwork() {
            return
        }
        
        if(hude){
            DispatchQueue.main.async {
                SVProgressHUD.show()
                SVProgressHUD.setDefaultMaskType(.clear)
            }
        }
        
        self.callRequest(url, hude, loadingText, method: "DELETE", params: [String : Any]()) { responce, statusCode in
            networkHandler(responce,statusCode)
        }
    }
    
    // get Request
    public func callRequest(_ url : URL,_ hude : Bool,_ loadingText : String, method: String, params : [String : Any], networkHandler:@escaping (_ responce : [String : Any], _ statusCode : Int) -> Void){
        let myGroup = DispatchGroup()
        myGroup.enter()
        
        var token = ""
        if let user = Auth.auth().currentUser {
            // The user is signed in
            user.getIDTokenForcingRefresh(true) { (idToken, error) in
                if error != nil {
//                    print("Error refreshing ID token: \(error.localizedDescription)")
                    myGroup.leave()
                } else if let idToken = idToken {
                    token = idToken
                    myGroup.leave()
                }
            }
        } else {
//            print("User is not signed in.")
            myGroup.leave()
        }
        
        myGroup.notify(queue: .main) {
            var request = URLRequest(url:url)
            request.httpMethod = method
            if params.count > 0 {
                request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
            }
            
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "accept")
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.addValue("iOS", forHTTPHeaderField: "platform-Type")
            
#if DEBUG
            print("URL",  url)
            print("URL PARAM",  params)
            print("URL :- ", request)
#endif
            let session = URLSession.shared
            let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                }
                
                if error != nil {
                    print("Error occurred: "+(error?.localizedDescription)!)
                    DispatchQueue.main.async {
                        networkHandler([String : Any](), 0)
                        Alert(title: kError, message: error!.localizedDescription, vc: RootViewController.controller!)
                    }
                    return;
                }
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options : .mutableLeaves) as! [String : Any]
                    DispatchQueue.main.sync {
                        if let _status = json["status"] as? Bool, _status == false{
                            if let strReason = json["message"] as? String, strReason == "custom-403-access-denied(GatewayResponseAuthorizerFailure)"{
                                AlertWithOkAction(title: kError, message: "You session is expired, please login again", vc: RootViewController.controller!){action in
                                    if(action == 1){
                                        do{
                                            try Auth.auth().signOut()
                                            Messaging.messaging().unsubscribe(fromTopic: CurrentUserInfo.userId) { error in
                                                if let error = error {
                                                    print("Error unsubscribing from topic: \(error.localizedDescription)")
                                                } else {
                                                    print("Successfully unsubscribed from topic!")
                                                }
                                            }
                                            CurrentUserInfo.email = nil
                                            CurrentUserInfo.phone = nil
                                            CurrentUserInfo.vehicleNumber = nil
                                            CurrentUserInfo.userName = nil
                                            CurrentUserInfo.profileUrl = nil
                                            CurrentUserInfo.language = nil
                                            CurrentUserInfo.location = nil
                                            CurrentUserInfo.userId = nil
                                            
                                            let  appDelegate = UIApplication.shared.delegate as? AppDelegate
                                            appDelegate?.autoLogin()
                                        }catch{
                                        }
                                    }
                                }
                                networkHandler(json, 403)
                                return
                            }
                        }
#if DEBUG
                        print(json);
#endif
                        networkHandler(json, 200)
                    }
                } catch let jsonError{
                    print(jsonError)
                    networkHandler([String : Any](), 0)
                    DispatchQueue.main.async {
                        Alert(title: kError, message: jsonError.localizedDescription, vc: RootViewController.controller!)
                    }
                }
            })
            task.resume()
            
        }
    }
    
    public func imageDataUploadRequest(_ url: URL, HUD:Bool,showSystemError:Bool,loadingText:Bool, param: Data,contentType:String, completionHandler:@escaping (_ response: Bool?, _ Error :Error? ) -> Void) {
        
        
        if(HUD){
            DispatchQueue.main.async {
                SVProgressHUD.show()
            }
        }
        
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(url: url)
        let session = URLSession.shared
        urlRequest.timeoutInterval = 180
        urlRequest.httpMethod = "PUT"
        urlRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        //        urlRequest.setValue("video/mp4", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("\(([UInt8](param)).count)", forHTTPHeaderField: "Content-Length")
        
        let task =  session.uploadTask(with: urlRequest as URLRequest, from: param) { (data, response, error) in
            // hide HUD
            DispatchQueue.main.async {
                //  Hide Activity Indicator here
                if(HUD){
                    SVProgressHUD.dismiss()
                }
            }
            
            if error != nil {
                print("Error occurred:"+(error?.localizedDescription)!)
                DispatchQueue.main.async {
                    completionHandler(nil, error! as Error)
                    //                        if showSystemError == true{
                    //                            Alert(title: "Error", message: error!.localizedDescription, vc: appDelegate)
                    //                        }
                }
                return;
            }
            else{
                if let httpResponse = response as? HTTPURLResponse {
                    if(httpResponse.statusCode == 200){
                        completionHandler(true,nil)
                        return
                    }
                    else{
                        let str = String(decoding: data ?? Data(), as: UTF8.self)
                        print(str)
                    }
                }
                else{
                    let str = String(decoding: data ?? Data(), as: UTF8.self)
                    print(str)
                }
                completionHandler(nil,nil)
                return
            }
        }
        
        task.resume()
    }
    
}

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}





