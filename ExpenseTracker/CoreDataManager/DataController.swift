//
//  DataController.swift
//  ExpenseTracker
//
//  Created by Rahul Patel on 23/01/22.
//

import UIKit
import CoreData
import CloudKit

class DataController: NSObject {

    //MARK: Shared Instance
    class var sharedInstance: DataController {
        struct Static {
            static let instance = DataController()
        }
        return Static.instance
    }
 
    
    func savePredefinedCategories() {
        
        let filepath: URL? = Bundle.main.url(forResource: "Categories", withExtension: "plist")
        let categoryPlistAry = NSMutableArray(contentsOf: filepath!)!
        
       let alreadySavedCategories = CoreDataManger.sharedInstance.fetchManageObjects(EntityName: "Category", sortDescriptorKey: "title", isAscending: true, resultPredicate: nil)
        
        if categoryPlistAry.count > 0 {
            
            for i in 0..<categoryPlistAry.count {
                
                let categoryDic = categoryPlistAry[i] as! NSDictionary
                let predicate = NSPredicate(format: "title == %@", categoryDic.object(forKey: "title") as! CVarArg)
                let resultAry = alreadySavedCategories.filtered(using: predicate)
                
                if resultAry.count == 0
                {
                    self.addNewCategory(title: categoryDic.object(forKey: "title") as! String, iconName: categoryDic.object(forKey: "imageName") as! String, hexColorValue : categoryDic.object(forKey: "hexColorValue") as! String )
                }
            }
        }
        CoreDataManger.sharedInstance.saveContext()
    
    }
    
    func addNewCategory(title : String, iconName : String, hexColorValue : String) {
        
        let categoryInfo = Category(context: CoreDataManger.sharedInstance.getContext())
        categoryInfo.title = title
        categoryInfo.imageName = iconName
        categoryInfo.hexColorValue = hexColorValue
    }

}
