//
//  TransactionsViewController.swift
//  ExpenseTracker
//
//  Created by Rahul Patel on 23/01/22.
//

import UIKit

class TransactionsViewController: UIViewController {
    
    // MARK:- IBOutlets
    @IBOutlet weak var tblExpenses: UITableView!
    @IBOutlet weak var lblTotalSpendTitle: UILabel!
    @IBOutlet weak var lblTotalSpend: UILabel!
    
    //MARK:- Global Variables
    
    var arrayofCategories : [Category]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        arrayofCategories = Helper.shared.SortyByMonth(Month: Date().getMonth, Year: Date().getYear)
        self.tblExpenses.register(UINib(nibName: "ExprenditureCell", bundle: nil), forCellReuseIdentifier: "ExprenditureCell")

    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareChatDataModel()

    }
    
    // MARK:- Data model getMethods
    private func prepareChatDataModel() {
        
        var grandTotal : Double = 0.00
        
        guard let resultData = arrayofCategories, resultData.count > 0 else {
            lblTotalSpend.text = grandTotal.getCurrencyFormat
            self.tblExpenses.reloadData()
            return
        }
        
        for category in resultData {
            let sum = (category.toTransactions?.value(forKeyPath: "amount") as? Double)
            grandTotal+=sum ?? 0.0
        }
        
        guard let resultData = arrayofCategories, resultData.count > 0 else {
            lblTotalSpend.text = grandTotal.getCurrencyFormat
            self.tblExpenses.reloadData()
            return
        }
        
        lblTotalSpend.text = grandTotal.getCurrencyFormat
        
        self.tblExpenses.estimatedRowHeight = 80.0
        self.tblExpenses.rowHeight = UITableView.automaticDimension
        self.tblExpenses.tableFooterView = UIView()
        
        self.tblExpenses.reloadData()
    }
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension TransactionsViewController : UITableViewDataSource, UITableViewDelegate
{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
            return arrayofCategories?.count ?? 0

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identifier = "ExprenditureCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! ExprenditureCell
        cell.category = arrayofCategories?[indexPath.row]
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
extension Double
{
    var getCurrencyFormat : String
    {
        let convertPrice = NSNumber(value: Double(self))
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        let convertedPrice = formatter.string(from: convertPrice)
        return convertedPrice!
    }
    
}
