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

class ScanViewController: UIViewController {
    let scanner = QRCode()
    var login_session:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("other view loaded")
        let preferences = UserDefaults.standard
        if preferences.object(forKey: "session") != nil {
            self.login_session = preferences.object(forKey: "session") as! String
        }
        scanner.prepareScan(view) { (stringValue) -> () in
            print(stringValue)
            self.scanner.stopScan()
            print(self.login_session)

            let headers: HTTPHeaders = [
                "Authorization": self.login_session
            ]
//            Alamofire.request("https://api.hackillinois.org/v1/tracking/"+stringValue, headers: headers).responseJSON { response in
//                print(response)
//            }
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
