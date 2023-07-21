//
//  concertsViewController.swift
//  Final Project
//
//  Created by Max Berry on 11/18/22.
//

import Foundation
import Firebase
import FirebaseStorage
import UIKit

class concertsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    
    public var latLong: String = ""
    var concerts: concertAPI? = nil
    var minDate: String = ""
    var maxDate: String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getDate()
        apiDecoder { data in
            self.latLong = data
            self.concertApiDecoder(location: self.latLong, min: self.minDate, max: self.maxDate) { [self] data in
                
                concerts = data
            }
            
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
    }
    

    func apiDecoder(completeion: @escaping (String) -> ()) {
        
        let headers = [
            "X-RapidAPI-Key": "e207380103msh9498d15ca4c3088p19742bjsn86cfcb22112e",
            "X-RapidAPI-Host": "telize-v1.p.rapidapi.com"
        ]

        let request = NSMutableURLRequest(url: NSURL(string: "https://telize-v1.p.rapidapi.com/geoip")! as URL,
                                                cachePolicy: .useProtocolCachePolicy,
                                            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
                
                let httpResponse = response as? HTTPURLResponse
                let decoder = JSONDecoder()
                do {
                    let ParsingData = try decoder.decode(geoAPI.self, from: data!)
                    let finalData = "\(ParsingData.city)"
                    completeion(finalData)
                } catch {
                    
                    print("error parsing")
                }
            }
        })

        dataTask.resume()
    }
    
    func concertApiDecoder(location: String, min: String, max: String, completeion: @escaping (concertAPI) -> ()) {

        let headers = [
            "X-RapidAPI-Key": "e207380103msh9498d15ca4c3088p19742bjsn86cfcb22112e",
            "X-RapidAPI-Host": "concerts-artists-events-tracker.p.rapidapi.com"
        ]

        let request = NSMutableURLRequest(url: NSURL(string: "https://concerts-artists-events-tracker.p.rapidapi.com/location?name=\(location)&minDate=\(min)&maxDate=\(max)&page=1")! as URL,
                                                cachePolicy: .useProtocolCachePolicy,
                                            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
            } else {

                let httpResponse = response as? HTTPURLResponse
                let decoder = JSONDecoder()
                do {
                    let ParsingData = try decoder.decode(concertAPI.self, from: data!)
                    completeion(ParsingData)
                } catch {
                    
                    print("error parsing")
                }
                
            }
        })

        dataTask.resume()
    }
    
    func getDate() {
        
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: date)
        let year: Int = components.year!
        
        let components2 = calendar.dateComponents([.month], from: date)
        let month: Int = components2.month!
        
        let components3 = calendar.dateComponents([.day], from: date)
        let dayOfMonth: Int = components3.day!
        
        if (month < 10 && dayOfMonth >= 10) {
            
            minDate = "\(year)-0\(month)-\(dayOfMonth)"
            maxDate = "\(year + 1)-0\(month)-\(dayOfMonth)"
        } else if (month >= 10 && dayOfMonth < 10) {
            
            minDate = "\(year)-\(month)-0\(dayOfMonth)"
            maxDate = "\(year + 1)-\(month)-0\(dayOfMonth)"
        } else if (month < 10 && dayOfMonth < 10) {
            
            minDate = "\(year)-0\(month)-0\(dayOfMonth)"
            maxDate = "\(year + 1)-0\(month)-0\(dayOfMonth)"
        } else {
            
            minDate = "\(year)-\(month)-\(dayOfMonth)"
            maxDate = "\(year + 1)-\(month)-\(dayOfMonth)"
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       
        return 90.0;
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! concertCells
        cell.layer.borderWidth = 1.0
        cell.concertName.text = concerts?.data[indexPath.row].name
        cell.concertDescription.text = concerts?.data[indexPath.row].description
    
        if (concerts?.data[indexPath.row].image) != nil {
            let profileURL2 = URL(string: (concerts!.data[indexPath.row].image))
            if profileURL2 != nil {
                
                getData(from: profileURL2!) { data, response, error in
                    guard let data = data, error == nil else { return }
                    
                    DispatchQueue.main.async() { [weak self] in
                        cell.concertImage.image = UIImage(data: data)
                    }
                }
            }
        } else {
            
            cell.concertImage.image = UIImage(named: "empty.jpeg")
        }
        
        return cell
       
    }
   
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
  
       return true
    }
   
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
       
        return UITableViewCell.EditingStyle.delete
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let alert = UIAlertController(title: "Would you like to save this concert?", message: "If you save this concert, you can accesss it later in your profile where you will be able to view more information about the show.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Save Concert", style: .default, handler: { [self] action in
            
            let db = Database.database().reference()
            let uid = Auth.auth().currentUser?.uid
            var count: Int? = 0
            var countInt: Int = 0
            
            
            db.child("users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
                
                let dic = snapshot.value as? [String : Any]

                DispatchQueue.main.async {
                      
                    count = dic!["count"] as! Int
                    countInt = count! + 1
                    db.child("users").child(uid!).updateChildValues(["count": countInt as Any])
                    db.child("users").child(uid!).child("concerts").child(String(count!)).updateChildValues(["title": self.concerts?.data[indexPath.row].name as Any])
                    db.child("users").child(uid!).child("concerts").child(String(count!)).updateChildValues(["description": self.concerts?.data[indexPath.row].description as Any])
                    db.child("users").child(uid!).child("concerts").child(String(count!)).updateChildValues(["image": self.concerts?.data[indexPath.row].image as Any])
                }

            })

            
            return
        
            print("row: \(indexPath.row)")
        }))
    
        self.present(alert, animated: true)
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }

}

