//
//  AuthViewControler.swift
//  Mymap
//
//  Created by 浅野未央 on 2017/07/20.
//  Copyright © 2017年 mio. All rights reserved.
//

import UIKit
import FirebaseAuth

class AuthViewControler: UIViewController {

  @IBOutlet weak var EmailFeild: UITextField!
  
  @IBOutlet weak var PasswordFeild: UITextField!
  
  var uid = ""
  
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
    // 入力されたデータを保持
    let email = EmailFeild.text
    let password = PasswordFeild.text

    
    // 入力された文字を非表示モードにする
    PasswordFeild.isSecureTextEntry = true
    
    // 認証処理
    Auth.auth().signIn(withEmail: email!, password: password!, completion: {(user, error) in
      
      // 認証できなければエラーを表示
      guard let _ = user else {
        if let error = error {
          if let errCode = AuthErrorCode(rawValue: error._code) {
            switch errCode {
            case .userNotFound:
              
              // Eメールアドレスがなかった場合
              self.showAlert("User account not found. Try registering")
            case .wrongPassword:
              
              // Eメールアドレスとパスワードの不一致の場合
              self.showAlert("Incorrect username/password combination")
            default:
              
              // 上記以外のエラー表示
              self.showAlert("Error: \(error.localizedDescription)")
            }
          };
          return
          
        };
        assertionFailure("user and error are nil");
        return
      }
      self.signIn()
    })
     }
  
  @IBAction func didTapRegister(_ sender: Any) {
    // 認証情報を保持
    let email = EmailFeild.text
    let password = PasswordFeild.text
    
    // 認証処理
    Auth.auth().createUser(withEmail: email!, password: password!, completion: { (user, error) in
      if let error = error {
        if let errCode = AuthErrorCode(rawValue: error._code) {
          switch errCode {
          case .invalidEmail:
            
            // メールアドレスに不備
            self.showAlert("Enter a valid email.")
          case .emailAlreadyInUse:
            
            // 既に登録済み
            self.showAlert("Email already in use.")
            default:
              
              // 上記以外のエラー
              self.showAlert("Error: \(error.localizedDescription)")
          }
        }
        return
      }
      self.signIn()
    })

  }
  
  func showAlert(_ message: String) {
    
    let alertController = UIAlertController(title: "mapmemo", message: message, preferredStyle:UIAlertControllerStyle.alert)
    
    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
    
    self.present(alertController, animated: true, completion: nil)
  }
  
  func signIn() {
    dismiss(animated: true, completion: nil)
  }

  @IBAction func didTapCancel(_ sender: Any) {
    signIn()
  }
  
  
}
