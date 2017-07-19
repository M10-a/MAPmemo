//
//  AuthViewControler.swift
//  Mymap
//
//  Created by 浅野未央 on 2017/07/20.
//  Copyright © 2017年 mio. All rights reserved.
//

import UIKit

class AuthViewControler: UIViewController {

  @IBOutlet weak var EmailFeild: UITextField!
  
  @IBOutlet weak var PasswordFeild: UITextField!
  
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

  @IBAction func didTapSignIn(_ sender: Any) {
  }
  
  @IBAction func didTapRegister(_ sender: Any) {
  }
  
}
