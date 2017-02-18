//
//  ScanViewController.swift
//  HackIllinois: QR
//
//  Created by Yasha Mostofi on 2/14/17.
//  Copyright © 2017 Yasha Mostofi. All rights reserved.
//

import UIKit
import AVFoundation
import SwiftQRCode
import Alamofire
import Foundation

class ScanViewController: BaseViewController {
    let scanner = QRCode()

    @IBOutlet var add_event: UIBarButtonItem!
//    @IBOutlet var add_event: UIButton!
//    @IBAction func addEventButton(_ sender: Any) {
//        print("button clicked")
//        if self.check_permissions(key: self.login_session) != "ADMIN" {
//            return
//        }
//        
//    }
    @IBAction func addEventButton(_ sender: Any) {
        print("button clicked")
        if self.check_permissions(key: self.login_session) != "ADMIN" {
            return
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print("other view loaded")
        let preferences = UserDefaults.standard
        if preferences.object(forKey: "session") != nil {
            self.login_session = preferences.object(forKey: "session") as! String
        }
        print(self.check_permissions(key: self.login_session))
        if self.check_permissions(key: self.login_session) == "ADMIN" {
//            self.add_event.isHidden = false
            self.add_event.isEnabled = true
        }
        else {
//            self.add_event.isHidden = true
            self.add_event.isEnabled = false
        }
        scanner.prepareScan(view) { (stringValue) -> () in
            print(stringValue)
            self.scanner.stopScan()
            print(self.login_session)
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
        scanner.scanFrame = view.bounds
        scanner.startScan()
    }
}
