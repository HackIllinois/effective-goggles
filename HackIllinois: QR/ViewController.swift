//
//  ViewController.swift
//  HackIllinois: QR
//
//  Created by Yasha Mostofi on 2/12/17.
//  Copyright © 2017 Yasha Mostofi. All rights reserved.
//

import UIKit
import AVFoundation
import SwiftQRCode
import Alamofire
import Foundation

class ViewController: UIViewController {
    @IBOutlet var email_input: UITextField!
    @IBOutlet var password_input: UITextField!
    @IBOutlet var login_button: UIButton!
    @IBAction func DoLogin(_ sender: AnyObject) {
        logIn(email:email_input.text!, password: password_input.text!)
    }
    let login_url = "https://api.hackillinois.org/v1/auth"
    let checksession_url = "https://api.hackillinois.org/v1/auth/reset"
    var login_session:String = ""
    
    let scanner = QRCode()

    override func viewDidLoad() {
        super.viewDidLoad()
        print("view loaded")
        
        scanner.prepareScan(view) { (stringValue) -> () in
            print(stringValue)
        }
        scanner.scanFrame = view.bounds
        
//        email_input.text = "try@me.com"
//        password_input.text = "test"
        
        let preferences = UserDefaults.standard
        if preferences.object(forKey: "session") != nil
        {
            login_session = preferences.object(forKey: "session") as! String
            check_session(key: login_session)
            scanner.startScan()
        }
    }
    
    func logIn(email: String, password: String) {
         let parameters: Parameters = [
             "email": email,
             "password": password
         ]
         
         // Both calls are equivalent
         Alamofire.request("https://api.hackillinois.org/v1/auth", method: .post,
             parameters: parameters,
             encoding: JSONEncoding.default).responseJSON { response in
         //            print(response.request)  // original URL request
         //            print(response.response) // HTTP URL response
         //            print(response.data)     // server data
         //            print(response.result)   // result of response serialization
         
             if let json = response.result.value {
                 if let jsonDict = json as? [String: Any] {
                     if let dataVal = jsonDict["data"] as? [String: Any] {
                         if let authKey = dataVal["auth"] as? String {
                            self.login_session = authKey
                            let preferences = UserDefaults.standard
                            preferences.set(authKey, forKey: "session")
                            print(authKey)
                            self.scanner.startScan()
                         }
                     }
                 }
             }
         }
    }
    
    func check_session(key: String) {
        let parameters: Parameters = [
            "Authorization": key
        ]
        
        // Both calls are equivalent
        Alamofire.request("https://api.hackillinois.org/v1/auth/refresh", method: .get,
          parameters: parameters,
          encoding: JSONEncoding.default).responseJSON { response in
            //            print(response.request)  // original URL request
            //            print(response.response) // HTTP URL response
            //            print(response.data)     // server data
            //            print(response.result)   // result of response serialization
            
            if let json = response.result.value {
                if let jsonDict = json as? [String: Any] {
                    if let dataVal = jsonDict["data"] as? [String: Any] {
                        if let authKey = dataVal["auth"] as? String {
                            self.login_session = authKey
                            let preferences = UserDefaults.standard
                            preferences.set(authKey, forKey: "session")
                            print(authKey)
                        }
                    }
                }
            }
        }

    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

