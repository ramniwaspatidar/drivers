//
//  APIHelper.swift
//  ReEnergy
//
//  Created by Lavanya Patidar on 06/02/22.
//

import Foundation

class APIHelper {
    
    class func parseArray(_ result: [String:Any], _ showError:Bool, completionHandler:@escaping (_ payload: [[String:Any]],_ status: Bool,_ message:String,_ code:Int ) -> Void){
        var array:[[String:Any]]
        var message:String
        var code:Int
        var status:Bool
        
        array = [[String:Any]]()
        message = ""
        code = 200
        status = false
        
        if let _status = result["status"] as? Bool{
            if(_status == true){
                status = true
                if (result["payload"] as? [[String:Any]]) != nil{
                    array = result["payload"] as! [[String:Any]]
                }
                else if (result["data"] as? [String:Any]) != nil{
                  let  dict = result["data"] as! [String:Any]
                    array = dict["rows"] as! [[String:Any]]
                }
                else if (result["data"] as? [String:Any]) != nil{
                    let  dict = result["data"] as! [String:Any]
                      array = dict["items"] as! [[String:Any]]
                  }
            }
            else{
                status = false
                if showError == true {
                    DispatchQueue.main.async {
                        if let strReason = result["message"] as? String{
//                            Alert(title: kError, message:strReason, vc: RootViewController.controller!)
                        }
                    }
                }
            }
            message = result["message"] as? String ?? ""
            code = 200
        }
        else{
            if showError == true {
                DispatchQueue.main.async {
                    if let message = result["message"] as? String{
                        Alert(title: kError, message:message, vc: RootViewController.controller!)
                    }
                    else{
                        Alert(title: kError, message:NSLocalizedString("Something went wrong", comment: ""), vc: RootViewController.controller!)
                    }
                }
            }
        }
        
        completionHandler(array,status,message,code)
    }
    
    class func parseObject(_ result: [String:Any], _ showError:Bool, completionHandler:@escaping (_ payload: [String:Any],_ status: Bool,_ message:String,_ code:Int ) -> Void){
        var object:[String:Any]
        var message:String
        var code:Int
        var status:Bool
        
        object = [String:Any]()
        message = ""
        code = 200
        status = false
        
        if let _status = result["status"] as? Bool{
            if(_status == true){
                status = true
                if (result["payload"] as? [String:Any]) != nil{
                    object = result["payload"] as! [String:Any]
                }
            }
            else{
                status = false
                if showError == true {
                    DispatchQueue.main.async {
                        if let strReason = result["message"] as? String{
                            DispatchQueue.main.async {
                                Alert(title: kError, message:strReason, vc: RootViewController.controller!)

                            }
                        }
                    }
                }
            }
            message = result["message"] as? String ?? result["messages"] as? String ?? ""

        }
        else{
            if showError == true {
                if let message = result["message"] as? String{
                    Alert(title: kError, message:message, vc: RootViewController.controller!)
                }
                else {
                    DispatchQueue.main.async {
                        Alert(title: kError, message:NSLocalizedString("Something went wrong", comment: ""), vc: RootViewController.controller!)
                    }

                }
            }
        }
        
        completionHandler(object,status,message,code)
    }
}
