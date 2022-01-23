//
//  ExprenditureCell.swift
//  ExpenseTracker
//
//  Created by Rahul Patel on 23/01/22.
//

import UIKit

class ExprenditureCell: UITableViewCell {

    @IBOutlet weak var imgView_Icon: UIImageView!
    @IBOutlet weak var lblCategoryName: UILabel!
    @IBOutlet weak var lblTotalSum: UILabel!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var category : Category?  {
            
        didSet{
            self.imgView_Icon.image = UIImage.init(named: category?.imageName ?? "")
            self.lblCategoryName.text = category?.title
            self.lblTotalSum.text = "Total \(self.sumTransactionAmount())"
        }
    }
    
    private func sumTransactionAmount() -> String
    {
        let sum = category?.toTransactions?.value(forKeyPath: "amount") as? Double
        return sum?.getCurrencyFormat ?? ""
    }
    
    
}
