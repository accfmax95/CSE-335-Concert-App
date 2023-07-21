//
//  concertCells.swift
//  Final Project
//
//  Created by Max Berry on 11/20/22.
//

import UIKit

class concertCells: UITableViewCell {

    @IBOutlet weak var concertName: UILabel!
    @IBOutlet weak var concertDescription: UILabel!
    @IBOutlet weak var concertImage: UIImageView! {
        
        didSet {
                
                concertImage.layer.cornerRadius = concertImage.bounds.width / 2
                concertImage.clipsToBounds = false
                concertImage.image = UIImage(named: "empty.jpeg")
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
