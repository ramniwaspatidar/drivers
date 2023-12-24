
import Foundation
import Alamofire
import SVProgressHUD
import JWTDecode

class NetworkManager {
    static var shared  = NetworkManager()
    
    private init(){}
    
  
    // post Request
    public func postRequest(_ url : URL,_ hude : Bool,_ loadingText : String, params : [String : Any], networkHandler:@escaping ((_ responce : [String : Any], _ statusCode : Int) -> Void)){
        if !ReachabilityTest.isConnectedToNetwork() {
            return
        }
        SVProgressHUD.show(withStatus: "Loading...")
        SVProgressHUD.setDefaultMaskType(.clear)
 
        self.callRequest(url, hude, loadingText, method: "POST", params: params) { responce, statusCode in
            networkHandler(responce,statusCode)
        }
    }
    
    public func putRequest(_ url : URL,_ hude : Bool,_ loadingText : String, params : [String : Any], networkHandler:@escaping ((_ responce : [String : Any], _ statusCode : Int) -> Void)){
        if !ReachabilityTest.isConnectedToNetwork() {
            return
        }
        SVProgressHUD.show(withStatus: "Loading...")
        SVProgressHUD.setDefaultMaskType(.clear)
 
        self.callRequest(url, hude, loadingText, method: "PUT", params: params) { responce, statusCode in
            networkHandler(responce,statusCode)
        }
    }
    
    
    // get Request
    public func getRequest(_ url : URL,_ hude : Bool,_ loadingText : String, networkHandler:@escaping ((_ responce : [String : Any], _ statusCode : Int) -> Void)){
        
        if !ReachabilityTest.isConnectedToNetwork() {
            return
        }

        SVProgressHUD.show(withStatus: "Loading...")
        SVProgressHUD.setDefaultMaskType(.clear)
        
        
        self.callRequest(url, hude, loadingText, method: "GET", params: [String : Any]()) { responce, statusCode in
            networkHandler(responce,statusCode)
        }
    }
    
    // get Request
    public func callRequest(_ url : URL,_ hude : Bool,_ loadingText : String, method: String, params : [String : Any], networkHandler:@escaping (_ responce : [String : Any], _ statusCode : Int) -> Void){
        let myGroup = DispatchGroup()
        myGroup.enter()
        if CurrentUserInfo.expired {
            var dictParam = [String : AnyObject]()
            dictParam["userName"] = "" as AnyObject
            dictParam["password"] = "" as AnyObject
            dictParam["grant_type"] = "refresh_token" as AnyObject
            dictParam["refreshToken"] = CurrentUserInfo.refreshToken as AnyObject
            var request = URLRequest(url:url)
            request.httpMethod = method
            request.httpBody = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "accept")
            let session = URLSession.shared
            let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
                do {
                    if let json = try JSONSerialization.jsonObject(with: data!, options : .mutableLeaves) as? [String : Any]{
                        if let data = json["data"] as? [String : Any] {
                            if let accToken = data["accessToken"] as? String{
                                CurrentUserInfo.accessToken = accToken
                            }
                            if let refToken = data["refreshToken"] as? String{
                                CurrentUserInfo.refreshToken = refToken
                            }
                            myGroup.leave()
                        }
                        else{
                            if let message = json["message"] as? String {
                                networkHandler([String : Any](), 0)
                                DispatchQueue.main.async {
                                    Alert(title: kError, message: message, vc: RootViewController.controller!)

                                }
                            }
                            else{
                                networkHandler([String : Any](), 0)
                                DispatchQueue.main.async {
                                    Alert(title: kError, message:NSLocalizedString("Something went wrong", comment: ""), vc: RootViewController.controller!)
                                }
                            }
                        }
                    }
                } catch let jsonError{
                    networkHandler([String : Any](), 0)
                    DispatchQueue.main.async {
                        Alert(title: kError, message: jsonError.localizedDescription, vc: RootViewController.controller!)
                    }
                }
            })
            task.resume()
        }
        else{
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
            if let token = CurrentUserInfo.accessToken as String?{
                request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            
            request.addValue("\(CurrentUserInfo.language ?? "en")", forHTTPHeaderField: "Accept-Language")

            #if DEBUG
            print("URL",  url)
            print("URL PARAM",  params)
            print("URL Headers:- ", request.headers)
            print("URL :- ", request)
            #endif
            let session = URLSession.shared
            let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
                SVProgressHUD.dismiss()
               
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
    
//    func uploadImage(_ url : URL,_ params : [String : Any],_ fileName: String,_ image: UIImage,_ hude : Bool, networkHandler:@escaping ((_ responce : [String : Any], _ statusCode : Int) -> Void)) {
//
//        if !ReachabilityTest.isConnectedToNetwork() {
//            return
//        }
//        SVProgressHUD.show(withStatus: "Loading...")
//        SVProgressHUD.setDefaultMaskType(.clear)
//        let myGroup = DispatchGroup()
//        myGroup.enter()
//        if CurrentUserInfo.expired {
//            guard let url = URL(string: Configuration().environment.baseURL + APIsEndPoints.ksignupUser.rawValue) else {return}
//            var dictParam = [String : AnyObject]()
//            dictParam["userName"] = "" as AnyObject
//            dictParam["password"] = "" as AnyObject
//            dictParam["grant_type"] = "refresh_token" as AnyObject
//            dictParam["refreshToken"] = CurrentUserInfo.refreshToken as AnyObject
//            var request = URLRequest(url:url)
//            request.httpMethod = "POST"
//            request.httpBody = try? JSONSerialization.data(withJSONObject: dictParam, options: [])
//            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//            request.addValue("application/json", forHTTPHeaderField: "accept")
//            let session = URLSession.shared
//            let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
//                do {
//                    if let json = try JSONSerialization.jsonObject(with: data!, options : .mutableLeaves) as? [String : Any]{
//                        if let data = json["data"] as? [String : Any] {
//                            if let accToken = data["accessToken"] as? String{
//                                CurrentUserInfo.accessToken = accToken
//                            }
//                            if let refToken = data["refreshToken"] as? String{
//                                CurrentUserInfo.refreshToken = refToken
//                            }
//                            myGroup.leave()
//                        }
//                        else{
//                            if let message = json["message"] as? String {
//                                networkHandler([String : Any](), 0)
//                                Alert(title: kError, message: message, vc: RootViewController.controller!)
//                            }
//                            else{
//                                networkHandler([String : Any](), 0)
//                                DispatchQueue.main.async {
//                                    Alert(title: kError, message:NSLocalizedString("Something went wrong", comment: ""), vc: RootViewController.controller!)
//                                }
//                            }
//                        }
//                    }
//                } catch let jsonError{
//                    networkHandler([String : Any](), 0)
//                    DispatchQueue.main.async {
//                        Alert(title: kError, message: jsonError.localizedDescription, vc: RootViewController.controller!)
//                    }
//                }
//            })
//            task.resume()
//        }
//        else{
//            myGroup.leave()
//        }
//        myGroup.notify(queue: .main) { [self] in
//
//            var request = URLRequest(url:url)
//            request.httpMethod = "PUT"
//
//            let boundary = self.generateBoundaryString()
//
//            let contentType = NSString(format: "multipart/form-data; boundary=%@",boundary)
//            request.addValue(contentType as String   , forHTTPHeaderField: "Content-Type")
//
//            let imageData = image.jpegData(compressionQuality: CGFloat(0.4))
//
//            request.httpBody = self.postBodyWithParameters(params, filePathKey: fileName, imageDataKey: imageData!, boundary: boundary)
//            request.addValue("application/json", forHTTPHeaderField: "accept")
//            if let token = CurrentUserInfo.accessToken as String?{
//                request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//            }
//            request.addValue("\(CurrentUserInfo.language ?? "en")", forHTTPHeaderField: "Accept-Language")
//
//            let session = URLSession.shared
//            let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
//                SVProgressHUD.dismiss()
//                print("data :-", data)
//                print("response :-", response)
//                print("error :-", error)
//                if error != nil {
//                    print("Error occurred: "+(error?.localizedDescription)!)
//                    DispatchQueue.main.async {
//                        networkHandler([String : Any](), 0)
//                        Alert(title: kError, message: error!.localizedDescription, vc: RootViewController.controller!)
//                    }
//                    return;
//                }
//                do {
//                    let json = try JSONSerialization.jsonObject(with: data!, options : .mutableLeaves) as! [String : Any]
//                    DispatchQueue.main.sync {
//                        #if DEBUG
//                            print(json);
//                        #endif
//                        networkHandler(json, 200)
//                    }
//                } catch let jsonError{
//                    print(jsonError)
//                    networkHandler([String : Any](), 0)
//                    DispatchQueue.main.async {
//                        Alert(title: kError, message: jsonError.localizedDescription, vc: RootViewController.controller!)
//                    }
//                }
//            })
//            task.resume()
//
//        }
//    }
    
    func generateBoundaryString() -> String {
        return "Boundary-\(UUID().uuidString)"
    }
    
//    func postBodyWithParameters(_ params : [String : Any], filePathKey: String?, imageDataKey: Data, boundary: String) -> Data {
//        let lineBreak = "\r\n"
//        var body = Data()
//        for (key, value) in params {
//            body.append("--\(boundary + lineBreak)")
//            body.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak + lineBreak)")
//            body.append("\(value as! String + lineBreak)")
//        }
//
//        let date = Date()
//        let filename : String =  "\(String(format: "%1.0f", date.timeIntervalSince1970.rounded())).jpg"
//        let mimetype = "image/jpg"
//        body.append("--\(boundary + lineBreak)")
//        body.append("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\(lineBreak)")
//        body.append("Content-Type: \(mimetype + lineBreak + lineBreak)")
//        body.append(imageDataKey)
//        body.append(lineBreak)
//
//        body.append("--\(boundary)--\(lineBreak)")
//        return body
//    }
}

extension Data {
   mutating func append(_ string: String) {
      if let data = string.data(using: .utf8) {
         append(data)
      }
   }
}





