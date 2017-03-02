/**
 * Copyright © 2017, Yasha Mostofi
 *
 * This is open source software, released under the University of
 * Illinois/NCSA Open Source License. You should have received a copy of
 * this license in a file with the distribution.
 **/

import UIKit
import Alamofire
import SwiftyJSON

class AddViewController: BaseViewController {
    // IBOutlets
    @IBOutlet var nameField: UITextField!
    @IBOutlet var durationField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let key = self.get_key() {
            self.login_session = key
        }
        else {
            self.dismiss(animated: true)
        }
    }
  
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func saveButton(_ sender: Any) {
        // Check for permissions again
        let role = self.check_permissions(key: self.login_session)
        if role != "ADMIN" {
            // Can't use `new event`
            self.dismiss(animated: true)
            return
        }
        
        // Set up POST request
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
                                // TODO: Error handling
                                // self?.displayAlert(title: "ERROR!", message: "Could not create new event")
                                self?.dismiss(animated: true)
                            }
        }
    }
}
