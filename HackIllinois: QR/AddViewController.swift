//
//  AddViewController.swift
//  HackIllinois: QR
//
//  Created by Yasha Mostofi on 2/18/17.
//  Copyright © 2017 Yasha Mostofi. All rights reserved.
//

import UIKit

class AddViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func cancelButton(_ sender: Any) {
        print("cancel")
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func saveButton(_ sender: Any) {
        print("save")
        self.dismiss(animated: true, completion: nil)
    }
}
