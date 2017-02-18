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
import JWTDecode


class BaseViewController: UIViewController {
    var login_session = ""

    func check_permissions(key: String) -> String {
        let jwt: JWT = try! decode(jwt: key)
        let json = JSON(jwt.body)
        let role = json["roles"][0]["role"].rawString()
        if (role == "STAFF" || role == "VOLUNTEER") {
            return "SCAN"
        }
        else if (role == "ADMIN")
        {
            return "ADMIN"
        }
        else {
            return "NONE"
        }
    }
    
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "Okay", style: .default)
        alert.addAction(okayAction)
        DispatchQueue.main.async { [weak self] in
            self?.present(alert, animated: true) {
            }
        }
    }
}

class ViewController: BaseViewController {
    @IBOutlet var email_input: UITextField!
    @IBOutlet var password_input: UITextField!
    @IBOutlet var login_button: UIButton!
    @IBAction func DoLogin(_ sender: AnyObject) {
        logIn(email:email_input.text!, password: password_input.text!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view loaded")
        let nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.black
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        imageView.contentMode = .scaleAspectFit
        let image = UIImage(named: "hackillinois")
        imageView.image = image
        navigationItem.titleView = imageView
        email_input.text = "yasha.mostofi+vol@gmail.com"
        password_input.text = "qqqqqqqq"
        
        // TODO: make it so you don't have to click the log in each time
    }
    
    func logIn(email: String, password: String) {
        if email == "" && password == "" {
            let preferences = UserDefaults.standard
            if preferences.object(forKey: "session") != nil
            {
                login_session = preferences.object(forKey: "session") as! String
                check_session(key: login_session)
                let role = check_permissions(key: login_session)
                if (role == "SCAN" || role == "ADMIN") {
                    performSegue(withIdentifier: "ShowScanner", sender: self)
                }
                else {
                    displayAlert(title: "Error!", message: "Permissions error. Please contact HackIllinois Staff")
                }
            }
        }
        else {
            let parameters: Parameters = [
                "email": email,
                "password": password
            ]
            Alamofire.request("https://api.hackillinois.org/v1/auth", method: .post,
                parameters: parameters,
                encoding: JSONEncoding.default).validate().responseJSON { [weak self] response in
                var goodPassword:Bool = false
                switch response.result {
                    case .success:
                        goodPassword = true
                    case .failure:
                        goodPassword = false
                }
                if goodPassword {
                    if let json = response.result.value {
                        if let jsonDict = json as? [String: Any] {
                            if let dataVal = jsonDict["data"] as? [String: Any] {
                                if let authKey = dataVal["auth"] as? String {
                                    self?.login_session = authKey
                                    let preferences = UserDefaults.standard
                                    preferences.set(authKey, forKey: "session")
                                    if let strongSelf = self{
                                        strongSelf.check_session(key: strongSelf.login_session)
                                        let role = strongSelf.check_permissions(key: strongSelf.login_session)
                                        if (role == "ADMIN" || role == "SCAN") {
                                            strongSelf.performSegue(withIdentifier: "ShowScanner", sender: self)
                                        }
                                        else {
                                            strongSelf.displayAlert(title: "Error!", message: "Permissions error. Please contact HackIllinois Staff")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                else {
                    self?.displayAlert(title: "Error!", message: "Password is incorrect")
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
    
 }

