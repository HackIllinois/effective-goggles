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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("other view loaded")
        
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
        scanner.startScan()
    }
}
