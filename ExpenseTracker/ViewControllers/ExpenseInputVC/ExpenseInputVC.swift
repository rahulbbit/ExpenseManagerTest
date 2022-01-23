//
//  ViewController.swift
//  ExpenseTracker
//
//  Created by Rahul Patel on 23/01/22.
//

import UIKit

class ExpenseInputVC: UIViewController {
    
    
    // MARK:- IBOutlets
    @IBOutlet weak var txtTitle: UITextField?
    @IBOutlet weak var txtAmount: UITextField?
    @IBOutlet weak var txtCategory: UITextField?
    @IBOutlet weak var txtDate: UITextField?
    @IBOutlet weak var txtnotes: UITextField?
    @IBOutlet var txtFields : [UITextField]?
    
    
    //MARK:- Global Variables
    let datePicker = UIDatePicker()
    var currrentSeletedDate : Date! = nil
    var currentSelectedCategory : Category! = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        txtDate?.inputView = datePicker
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        self.showDatePicker()
        self.addbarButtonItems()
        self.title = "Expense Tracker"
    }
    
    // MARK:- Add BarButtons and Handlers
    
    private func addbarButtonItems(){
        
        let clearAllLeftBarButton = UIBarButtonItem.init(title: "Clear All", style: .done, target: self, action: #selector(clearAllBarButtonAction))
        self.navigationItem.leftBarButtonItem = clearAllLeftBarButton
        
        let saveRightBarButton = UIBarButtonItem.init(title: "Save", style: .done, target: self, action: #selector(saveOrUpdateBarButtonAction))
        self.navigationItem.rightBarButtonItem = saveRightBarButton
        
    }
    
    
    @objc private func clearAllBarButtonAction() {
        
    }
    
    
    
    @objc private func saveOrUpdateBarButtonAction() {
        if(self.validations())
        {
            self.saveTransaction()
        }
    }
    
    
    fileprivate func saveTransaction(){
        
        let transaction = Transaction(context: CoreDataManger.sharedInstance.getContext())
        transaction.title = self.txtTitle?.text?.trim()
        transaction.amount = self.txtAmount?.text?.trim().toDouble() ?? 0.0
        transaction.expeDate = self.currrentSeletedDate.getUTCDate
        transaction.transDate = Date()
        transaction.note = self.txtnotes?.text
        transaction.toCategory = self.currentSelectedCategory
        
        do {
            try CoreDataManger.sharedInstance.getContext().save()
            print("saved!")
            
            self.clearAllBarButtonAction()
            self.showAlertController(title: "Success", message: "Expense Saved", actions: [])
            
        } catch let error as NSError
        {
            print("Could not save \(error), \(error.userInfo)")
        }
        
    }
    
    fileprivate func validations() -> Bool
    {
        
        guard let title = self.txtTitle?.text?.trim(), title.count > 0 else {
            self.showAlertController(title: "Invalid Title", message: "Title cannot be empty.", actions: [])
            return false
        }
        
        guard let amount = self.txtAmount?.text?.trim(), amount.count > 0 else {
            self.showAlertController(title: "Invalid Amount", message: "Amount cannot be empty.", actions: [])
            return false
        }
        guard self.currentSelectedCategory != nil else {
            
            self.showAlertController(title: "Invalid Category", message: "Select a category.", actions: [])
            return false
        }
        
        guard self.currrentSeletedDate != nil else {
            self.showAlertController(title: "Invalid Date", message: "Select the expense date.", actions: [])
            return false
        }
        
        return true
    }
    
    
    fileprivate func showDatePicker(){
        //Formate Date
        datePicker.datePickerMode = .date
        
        //ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        
        //done button & cancel button
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(doneDatePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(cancelDatePicker))
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        
        // add toolbar to textField
        txtDate?.inputAccessoryView = toolbar
        // add datepicker to textField
        txtDate?.inputView = datePicker
        
    }
    
    @objc func doneDatePicker(){
        //For date formate
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        txtDate?.text = formatter.string(from: datePicker.date)
        currrentSeletedDate = datePicker.date
        //dismiss date picker dialog
        self.view.endEditing(true)
    }
    
    @objc func cancelDatePicker(){
        //cancel button dismiss datepicker dialog
        self.view.endEditing(true)
    }
    
 
    
    //MARK:- Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      
        
        if (segue.identifier == "categoryPicker")
        {
            let categoriesVC = segue.destination.children[0] as! CategorySelectionVC
            categoriesVC.expenseCategoryInputClosure = { (category) in
                self.txtCategory?.text = category.title
                self.currentSelectedCategory = category

            }
        }
        segue.destination.modalPresentationStyle = .custom
    }
    
}



extension String{
    
    func trim() -> String{
        return self.trimmingCharacters(in: CharacterSet.whitespaces)
    }
    
    
    func toDouble() -> Double {
        return NumberFormatter().number(from: self)?.doubleValue ?? 0.0
    }
    func toInteger() -> Int {
        return NumberFormatter().number(from: self)?.intValue ?? Int(0)
    }
}



extension UIViewController
{
    func showAlertController(title : String, message : String, actions : [UIAlertAction]?)
    {
        let alertController = UIAlertController(title: title , message: message, preferredStyle: .alert)
        
        if actions?.count == 0
        {
            let action1 = UIAlertAction.init(title: "Okay", style: .cancel, handler: nil)
            alertController.addAction(action1)
            
        }else
        {
            for action in actions ?? [] {
                alertController.addAction(action)
            }
        }
        self.present(alertController, animated: true, completion: nil)
    }
}


// MARK:- TextField Delegates
extension ExpenseInputVC : UITextFieldDelegate{
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        self.view .endEditing(true)

        switch textField {
        case txtCategory:
            self.performSegue(withIdentifier: "categoryPicker", sender: self)
            return false
        default:
            return true
        }
    }
 
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == txtAmount {
            guard let text = textField.text else { return true }
            let newLength = text.count + string.count - range.length
            return newLength <= 10
        }
        return true
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
