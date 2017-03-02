/**
 * Copyright © 2017, Yasha Mostofi
 *
 * This is open source software, released under the University of
 * Illinois/NCSA Open Source License. You should have received a copy of
 * this license in a file with the distribution.
 **/


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
        let roles = json["roles"].arrayValue.map { (role) -> String in
            return role.dictionaryValue["role"]!.stringValue
        }
        if roles.contains("ADMIN") { return "ADMIN" }
        else if roles.contains("STAFF") || roles.contains("VOLUNTEER") { return "SCAN" }
        else { return "NONE" }
    }
    
    func get_email(key: String) -> String {
        let jwt: JWT = try! decode(jwt: key)
        let json = JSON(jwt.body)
        return json["email"].rawString()!
    }
    
    func get_key() -> String? {
        let preferences = UserDefaults.standard
        if preferences.object(forKey: "session") != nil {
            return preferences.object(forKey: "session") as! String
        }
        else {
            return nil
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
    // IBOutlets and IBActions to Storyboard
    @IBOutlet var email_input: UITextField!
    @IBOutlet var password_input: UITextField!
    @IBOutlet var login_button: UIButton!
    @IBOutlet var acctInfo: UILabel!
    @IBAction func DoLogin(_ sender: AnyObject) {
        logIn(email:email_input.text!, password: password_input.text!)
    }
    @IBAction func signOutButton(_ sender: Any) {
        let preferences = UserDefaults.standard
        if let key = self.get_key() {
            acctInfo.text = get_email(key: key) + " signed out"
            acctInfo.textColor = UIColor.red
            preferences.removeObject(forKey: "session")
        }
        else {
            acctInfo.text = "Not logged in."
            acctInfo.textColor = UIColor.red
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up nav bar
        let nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.black
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        imageView.contentMode = .scaleAspectFit
        let image = UIImage(named: "hackillinois")
        imageView.image = image
        navigationItem.titleView = imageView
        
        // Get login session key
        if let key = self.get_key() {
            acctInfo.text = get_email(key: key) + " logged in"
            self.login_session = key
        }
        else {
            acctInfo.text = "Not signed in"
            acctInfo.textColor = UIColor.red
        }
        
        
        //email_input.text = "yasha.mostofi+vol@gmail.com"
//        email_input.text = "yasha.mostofi@hackillinois.org"
        
        
        // TODO: make it so you don't have to click the log in each time
    }
    
    func logIn(email: String, password: String) {
        // Validate input, sort of
        if email == "" || password == "" {
            // Try using key from storage
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
                    displayAlert(title: "Error!", message: "Permissions error. Please contact HackIllinois Staff.")
                }
            }
            else {
                displayAlert(title: "Error!", message: "Please enter your email and password.")
            }
        }
        else {
            // Auth user and save it in storage
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
                                    if let strongSelf = self {
                                        //strongSelf.check_session(key: strongSelf.login_session)
                                        strongSelf.acctInfo.text = strongSelf.get_email(key: authKey) + " logged in"
                                        strongSelf.acctInfo.textColor = UIColor.black
                                        // Check user ROLE for permissions
                                        let role = strongSelf.check_permissions(key: authKey)
                                        if (role == "ADMIN" || role == "SCAN") {
                                            strongSelf.performSegue(withIdentifier: "ShowScanner", sender: self)
                                        }
                                        else {
                                            strongSelf.displayAlert(title: "Error!", message: "Permissions error. Please contact HackIllinois Staff.")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                else {
                    self?.displayAlert(title: "Error!", message: "Password is incorrect.")
                }
            }
        }
    }
    
    // This refreshes the auth token, since they expire every 7 days
    // we just refresh constantly :)
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

