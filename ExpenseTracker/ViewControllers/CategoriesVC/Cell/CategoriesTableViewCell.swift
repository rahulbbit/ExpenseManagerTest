//
//  CategoriesTableViewCell.swift
//  ExpenseTracker
//
//  Created by Rahul Patel on 23/01/22.
//

import UIKit

class CategoriesTableViewCell: UITableViewCell {

    
    @IBOutlet weak var lblCategoryName: UILabel!
    @IBOutlet weak var imgCategoryImage: UIImageView!

    
 
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    var category: Category?
    {
        didSet
        {
            if let title = category?.title {
                self.lblCategoryName.text = title
            }
            
            if let name = category?.imageName {
                self.imgCategoryImage.image = UIImage.init(named: name)
            }
        }
        
    }
    
}
