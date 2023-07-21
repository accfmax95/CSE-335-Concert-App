//
//  savedConcertsViewController.swift
//  Final Project
//
//  Created by Max Berry on 11/18/22.
//

import Foundation
import Firebase
import FirebaseStorage
import UIKit


class savedConcertsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {

    var concerts: [concertTemp] = []
    @IBOutlet weak var count: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let db = Database.database().reference()
        let uid = Auth.auth().currentUser?.uid
        
        
        db.child("users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
            
            let dic = snapshot.value as? [String : Any]

            DispatchQueue.main.async { [self] in
                  
                var count2 = dic!["count"] as! Int
                self.count.text = String(count2)
                   
                for i in 0..<count2 {
                    
                    db.child("users").child(uid!).child("concerts").child(String(i)).observeSingleEvent(of: .value, with: { [self] (snapshot2) in
                        
                            let dic = snapshot2.value as? [String : Any]
                            var temp = dic!["title"] as! String
                            var temp2 = dic!["description"] as! String
                            var temp3 = dic!["image"] as! String

                            let savedConcert = concertTemp(description: temp2, image: temp3, name: temp)
                            concerts.append(savedConcert)
                        
                        if (i == count2 - 1) {
                            
                            tableView.delegate = self
                            tableView.dataSource = self
                            tableView.reloadData()
                        }

                    })
                }
            }

        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let count2 = self.count.text!
        let count3: Int? = Int(count2)
        
        if count3 != nil {
            
            return count3!
        } else {
            
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       
        return 90.0;
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath) as! savedCells
        cell.layer.borderWidth = 1.0
        cell.concertName2.text = concerts[indexPath.row].name
        cell.concertDescription2.text = concerts[indexPath.row].description
    
        if (concerts[indexPath.row].image) != nil {
            let profileURL2 = URL(string: (concerts[indexPath.row].image))
            if profileURL2 != nil {
                
                getData(from: profileURL2!) { data, response, error in
                    guard let data = data, error == nil else { return }
                    
                    DispatchQueue.main.async() { [weak self] in
                        cell.concertImage2.image = UIImage(data: data)
                    }
                }
            }
        } else {
            
            cell.concertImage2.image = UIImage(named: "empty.jpeg")
        }
        
        return cell
    }
   
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
  
       return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
       let alert = UIAlertController(title: "Want to know more about this concert?", message: "If you press the search button, we can redirect you to a list of Google results in order to find the details on how to purchase a ticket.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Search", style: .default, handler: { [self] action in
            
            var sentence = (concerts[indexPath.row].description.components(separatedBy: NSCharacterSet.decimalDigits) as NSArray).componentsJoined(by: "")
            var wordToRemove = "20"
            
            if let range = sentence.range(of: wordToRemove) {
               sentence.removeSubrange(range)
            }
            
            wordToRemove = "at --T::-"
            if let range = sentence.range(of: wordToRemove) {
               sentence.removeSubrange(range)
            }
            
            var searchTerm = "\(sentence)tickets"

            searchTerm = searchTerm.replacingOccurrences(of: " ", with: "+")
            var url = "https://www.google.com/search?q=\(searchTerm)"
            UIApplication.shared.open(URL(string: url)!, options: [:], completionHandler: nil)
            
            return
        
        }))
    
        self.present(alert, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
       
        return UITableViewCell.EditingStyle.delete
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
                        
            let db = Database.database().reference()
            let uid = Auth.auth().currentUser?.uid
            
            db.child("users").child(uid!).child("concerts").observeSingleEvent(of: .value, with: { (snapshot) in
                
                let dic = snapshot.value as? [String : Any]
                
                DispatchQueue.main.async {
                    
                    let OGcount = Int(self.count.text!)
                    var tempCount = Int(self.count.text!)
                    tempCount = tempCount! - 1
                    self.count.text =  String(tempCount!)
                    
                    db.child("users").child(uid!).updateChildValues(["count": Int(self.count.text!) as Any])
                    db.child("users").child(uid!).child("concerts").child(String(indexPath.row)).updateChildValues(["title": "" as Any])
                    db.child("users").child(uid!).child("concerts").child(String(indexPath.row)).updateChildValues(["description": "" as Any])
                    db.child("users").child(uid!).child("concerts").child(String(indexPath.row)).updateChildValues(["image": "" as Any])
                    self.concerts.remove(at: indexPath.row)

                    for i in 0..<OGcount! {
                        
                        if i > indexPath.row {
                            
                            db.child("users").child(uid!).child("concerts").child(String(i-1)).updateChildValues(["title": self.concerts[i - 1].name as Any])
                            db.child("users").child(uid!).child("concerts").child(String(i-1)).updateChildValues(["description": self.concerts[i-1].description as Any])
                            db.child("users").child(uid!).child("concerts").child(String(i-1)).updateChildValues(["image": self.concerts[i-1].image as Any])
                        }
                    }
                    
                    db.child("users").child(uid!).child("concerts").updateChildValues([String((tempCount!)): nil])
                    tableView.reloadData()
                }
            })
            
        }
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }

}
