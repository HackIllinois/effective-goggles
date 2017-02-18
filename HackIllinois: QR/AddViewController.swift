//
//  AddViewController.swift
//  HackIllinois: QR
//
//  Created by Yasha Mostofi on 2/18/17.
//  Copyright © 2017 Yasha Mostofi. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class AddViewController: BaseViewController {
    @IBOutlet var nameField: UITextField!
    @IBOutlet var durationField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        let preferences = UserDefaults.standard
        if preferences.object(forKey: "session") != nil
        {
            self.login_session = preferences.object(forKey: "session") as! String
        }
    }
  
    @IBAction func cancelButton(_ sender: Any) {
        print("cancel")
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func saveButton(_ sender: Any) {
        print("save")
        let role = self.check_permissions(key: self.login_session)
        print(role)
        if role != "ADMIN" {
            self.dismiss(animated: true)
            return
        }
        let headers: HTTPHeaders = [
            "Authorization": self.login_session
        ]
        let parameters: Parameters = [
            "name": nameField.text!,
            "duration": durationField.text!
        ]
        print(parameters)
        Alamofire.request("https://api.hackillinois.org/v1/tracking", method: .post,
                          parameters: parameters, encoding: JSONEncoding.default,
                          headers: headers).validate().responseJSON { [weak self] response in
                            print(response)
                            switch response.result {
                            case .success:
                                self?.dismiss(animated: true)
                            case .failure:
//                                self?.displayAlert(title: "ERROR!", message: "Could not create new event")
                                self?.dismiss(animated: true)
                            }
        }
    }
}
