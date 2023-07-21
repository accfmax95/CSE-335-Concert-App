//
//  ViewController.swift
//  CSE 335 Final Project
//
//  Created by Max Berry on 11/17/22.
//

import UIKit
import Firebase

class SignInViewController: UIViewController {
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func loginButton(_ sender: UIButton) {
        
        Auth.auth().signIn(withEmail: email.text!, password: password.text!) { result, error in
            if error != nil {
                
                let errorMes = UIAlertController(title: "Login Failed", message: "The information you provided was incorrect.", preferredStyle: .alert)
                
                errorMes.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                self.present(errorMes, animated: true)
            } else {
                
                self.performSegue(withIdentifier: "loginConfirmed", sender: self)
            }
        }
        
    }
    
}
