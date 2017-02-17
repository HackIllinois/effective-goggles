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
import SwiftyJSON

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view loaded")

        /*
        scanner.prepareScan(view) { (stringValue) -> () in
            print(stringValue)
            self.scanner.stopScan()
            let alert = UIAlertController(title: "data", message: stringValue, preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "okay", style: .default) { [weak self] (_) in
                self?.scanner.startScan()
            }
            alert.addAction(okayAction)
            DispatchQueue.main.async { [weak self] in
                self?.present(alert, animated: true) {
                }
            }
        }
        scanner.scanFrame = view.bounds
        */
        
        /*
        // Uncomment to save auth key between app opens
        let preferences = UserDefaults.standard
        if preferences.object(forKey: "session") != nil
        {
            login_session = preferences.object(forKey: "session") as! String
            check_session(key: login_session)
            scanner.startScan()
        }
        */
    }
    
    func logIn(email: String, password: String) {
        let preferences = UserDefaults.standard
        if preferences.object(forKey: "session") != nil
        {
            login_session = preferences.object(forKey: "session") as! String
        }
        else {
            let parameters: Parameters = [
                "email": email,
                "password": password
            ]
            Alamofire.request("https://api.hackillinois.org/v1/auth", method: .post,
                parameters: parameters,
                encoding: JSONEncoding.default).responseJSON { [weak self] response in
                if let json = response.result.value {
                    if let jsonDict = json as? [String: Any] {
                        if let dataVal = jsonDict["data"] as? [String: Any] {
                            if let authKey = dataVal["auth"] as? String {
                                self?.login_session = authKey
                                let preferences = UserDefaults.standard
                                preferences.set(authKey, forKey: "session")
                            }
                        }
                    }
                }
            }
        }
        check_session(key: login_session)
        let role = check_permissions(key: login_session)
        if (role == "SCAN" || role == "ALL") {
            performSegue(withIdentifier: "ShowScanner", sender: self)
        }
        else {
            let alert = UIAlertController(title: "Error", message: "Permissions error", preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "Okay", style: .default)
            alert.addAction(okayAction)
            DispatchQueue.main.async { [weak self] in
                self?.present(alert, animated: true) {
                }
            }
        }
    }
    
    func check_session(key: String) {
        let parameters: Parameters = [
            "Authorization": key
        ]
        Alamofire.request("https://api.hackillinois.org/v1/auth/refresh", method: .get,
          parameters: parameters,
          encoding: JSONEncoding.default).responseJSON { response in
            if let json = response.result.value {
                if let jsonDict = json as? [String: Any] {
                    if let dataVal = jsonDict["data"] as? [String: Any] {
                        if let authKey = dataVal["auth"] as? String {
                            self.login_session = authKey
                            let preferences = UserDefaults.standard
                            preferences.set(authKey, forKey: "session")
                        }
                    }
                }
            }
        }
    }
    
    func check_permissions(key: String) -> String {
        if let data = Data(base64Encoded: key.components(separatedBy: ".")[1]) {
            let json = JSON(data)
            // if voluteer, staff, or admin, they can scan
            // if admin, they can also create events
            let role = json["roles"].arrayValue[0]["role"].stringValue
            if (role == "STAFF" || role == "VOLUNTEER") {
                return "SCAN"
            }
            else if (role == "ADMIN")
            {
                return "ALL"
            }
            else {
                return "NONE"
            }
        }
        else {
            return "NONE"
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

