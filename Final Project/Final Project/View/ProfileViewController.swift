//
//  ProfileViewController.swift
//  Final Project
//
//  Created by Max Berry on 11/18/22.
//

import UIKit
import Firebase
import FirebaseStorage

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    @IBOutlet weak var newPass: UITextField!
    @IBOutlet weak var newEmail: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    var imagePicker = UIImagePickerController()
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 3
        imageView.layer.borderColor = UIColor.black.cgColor
        imageView.layer.cornerRadius = imageView.frame.height / 2
        
        let ref = Database.database().reference()
        
        ref.child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dic = snapshot.value as? [String : Any] {
                
                let email = dic["email"] as! String
                let pass = dic["password"] as! String
                let profileURl = dic["profileURL"] as! String
                
                
                self.newEmail.text = email
                self.newPass.text = pass
                
                let profileURL2 = URL(string: profileURl)
                if profileURL2 != nil {
                    
                    self.downloadImage(from: profileURL2!)
                }
            }
        })
  
    }
    

    @IBAction func logoutButton(_ sender: Any) {
        
        let auth = Auth.auth()
        
        do {
            
            try auth.signOut()
        } catch let error{
            
            self.present(UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert), animated: true, completion: nil)
        }
    }
    
    @IBAction func updateInfo(_ sender: Any) {
        
        let email = newEmail.text
        let pass = newPass.text
        
        let db = Database.database().reference()
        let uid = Auth.auth().currentUser?.uid
        
        if email != nil && pass != nil {
            db.child("users").child(uid!).updateChildValues(["email": email as Any])
            db.child("users").child(uid!).updateChildValues(["password": pass as Any])
            Auth.auth().currentUser?.updateEmail(to: email!){ error in
                if error != nil {
                    
                    print(email!)
                    return
                }
            }
            
            Auth.auth().currentUser?.updatePassword(to: pass!){ error in
                if error != nil {
                    
                    print(pass!)
                    return
                }
            }
            
            let mes = UIAlertController(title: "Information Updated", message: "Your email and password have been changed.", preferredStyle: .alert)
            
            mes.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            self.present(mes, animated: true)
        } else {
            
            let mes = UIAlertController(title: "Information Not Updated", message: "Make sure both fields are filled with a valid email and password.", preferredStyle: .alert)
            
            mes.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            self.present(mes, animated: true)
        }
        
    }
    
    @IBAction func updatePhoto(_ sender: Any) {
        
        let photoAlert = UIAlertController(title: "Photo Source", message: "", preferredStyle: .actionSheet)
        photoAlert.addAction(UIAlertAction(title: "Library", style: .default, handler: { [self]action in
            
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = false

            present(imagePicker, animated: true, completion: nil)
        }))
        
        photoAlert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [self]action in
           
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = false

            present(imagePicker, animated: true, completion: nil)
        }))
        
        self.present(photoAlert, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
           
        
            if let image = info[.originalImage] as? UIImage{
                
                imageView.image = image
                self.uploadProfilePicture(imageView.image!) { url in
                    
                    let db = Database.database().reference()
                    let uid = Auth.auth().currentUser?.uid
                    let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                    
                    changeRequest?.photoURL = url
                    changeRequest?.commitChanges { error in
                        if error == nil {
                            
                            db.child("users").child(uid!).updateChildValues(["profileURL": url?.absoluteString as Any])
                        } else {
                            
                            
                        }
                        
                    }
                }
            }
            
            self.dismiss(animated: true, completion: { () -> Void in
                
            })
    }
    
    func uploadProfilePicture(_ image: UIImage, completion: @escaping ((_ url: URL?) ->())) {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = Storage.storage().reference().child("user\(uid)")
        
        guard let imageData = image.jpegData(compressionQuality: 0.75) else { return }
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
        ref.putData(imageData, metadata: metaData) { metadata, error in
            
            if error == nil, metaData != nil {

                ref.downloadURL { url, error in
                    completion(url)
                    UserDefaults.standard.set(url, forKey: "profileURL")
                    // success!
                }
            } else {
                            // failed
                completion(nil)
            }
        }
        
    }
    
    func downloadImage(from url: URL) {
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            
            DispatchQueue.main.async() { [weak self] in
                self?.imageView.image = UIImage(data: data)
            }
        }
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }

}
