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

class ScanViewController: BaseViewController {
    // QR Scanner object
    let scanner = QRCode()

    // IBOutlet and IBAction
    @IBOutlet var add_event: UIBarButtonItem!
    @IBAction func addEventButton(_ sender: Any) {
        print("button clicked")
        if self.check_permissions(key: self.login_session) != "ADMIN" {
            return
        }
    }
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let key = self.get_key() {
            self.login_session = key
        }
        else {
            self.dismiss(animated: true)
        }
        if self.check_permissions(key: self.login_session) == "ADMIN" {
            self.add_event.isEnabled = true
        }
        else {
            self.add_event.isEnabled = false
        }
        // Prepare scanner object
        scanner.prepareScan(view) { (stringValue) -> () in
            print(stringValue)
            // Kill the scanner
            self.scanner.stopScan()
            print(self.login_session)
            
            // Set up POST request
            let headers: HTTPHeaders = [
                "Authorization": self.login_session
            ]
            Alamofire.request("https://api.hackillinois.org/v1/tracking/"+stringValue,
                headers: headers).validate().responseJSON { response in
                var message:String = ""
                var title:String = ""
                switch response.result {
                    case .success:
                        message = "Attendee can participate"
                        title = "Success!"
                    case .failure:
                        message = "Attendee has already participated"
                        title = "ERROR!"
                }
                // Alert user of POST result
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                let okayAction = UIAlertAction(title: "Okay", style: .default) { [weak self] (_) in
                    self?.scanner.startScan()
                }
                alert.addAction(okayAction)
                DispatchQueue.main.async { [weak self] in
                    self?.present(alert, animated: true) {
                    }
                }
            }
        }
        // Set bounds and start scanning
        scanner.scanFrame = view.bounds
        scanner.startScan()
    }
}
