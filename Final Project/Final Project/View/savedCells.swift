//
//  savedCells.swift
//  Final Project
//
//  Created by Max Berry on 11/21/22.
//
import UIKit

class savedCells: UITableViewCell {

    @IBOutlet weak var concertName2: UILabel!
    @IBOutlet weak var concertDescription2: UILabel!
    @IBOutlet weak var concertImage2: UIImageView! {
        
        didSet {
                
                concertImage2.layer.cornerRadius = concertImage2.bounds.width / 2
                concertImage2.clipsToBounds = false
                concertImage2.image = UIImage(named: "empty.jpeg")
            }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
