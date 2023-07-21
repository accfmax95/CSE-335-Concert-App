//
//  HomeViewController.swift
//  CSE 335 Final Project
//
//  Created by Max Berry on 11/17/22.
//

import UIKit
import Firebase

class HomeViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func signUpButton(_ sender: Any) {
        
        let alert = UIAlertController(title: "Sign Up", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Enter Email"
        })
        
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Enter Password"
        })
        
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Confirm Password"
        })
        
        alert.addAction(UIAlertAction(title: "Sign Up", style: .default, handler: { [self]action in
            
            let email = alert.textFields![0].text!
            let pass = alert.textFields![1].text!
            let pass2 = alert.textFields![2].text!
            let isEqual = (pass == pass2)
            
            if isEqual == false || email == "" || pass == "" || pass2 == "" {

                let errorMes = UIAlertController(title: "Account Not Added", message: "All fields must be filled and your passwords need to be the same.", preferredStyle: .alert)
                
                errorMes.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                self.present(errorMes, animated: true)
                
            } else {
                
                // Firebase code
                Auth.auth().createUser(withEmail: email, password: pass) { result, error in
                    if error != nil {
                        
                        let errorMes = UIAlertController(title: "Account Not Added", message: "There was a problem adding your account. Make sure you are choosing a password that contains atleast 6 characters, and you don't already have an account with this email address.", preferredStyle: .alert)
                        
                        errorMes.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                        self.present(errorMes, animated: true)
                    } else {
                        
                        let db = Database.database().reference()
                        let uid = Auth.auth().currentUser?.uid
                        let count = 0
                        
                        db.child("users").child(uid!).setValue(["email" : email, "password" : pass, "concerts" : "", "count" : count, "profileURL" : "", "UserID" : result!.user.uid])
                        
                        Auth.auth().signIn(withEmail: email, password: pass) { result, error in
                            if error != nil {
                                
                              
                            } else {
                                
                                let conMes = UIAlertController(title: "Congratulations!", message: "Your account has been Added! You can now access the home page.", preferredStyle: .alert)
                                
                                conMes.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                                
                                self.performSegue(withIdentifier: "goToNext", sender: self)
                                self.present(conMes, animated: true)
                            }
                        }
                        
                    }
                }
            

            }
            
        }))
        
        self.present(alert, animated: true)
    }
    
    @IBAction func unwindToOne(sender: UIStoryboardSegue) {
        
    }

}
