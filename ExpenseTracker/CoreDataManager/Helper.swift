//
//  Helper.swift
//  ExpenseTracker
//
//  Created by Rahul Patel on 23/01/22.
//

import Foundation
import UIKit

enum Sorting:Int{
    case Day = 1, Month = 2, Year = 3
}

class Helper: NSObject {

    var numberofYears : [String]?

    // MARK: - Shared Instance
    public static let shared = Helper()
    
    // MARK: - Default Months and Years Method

    func getNumberOfMonths() -> [String]
    {
        return ["January", "February", "March","April", "May", "June","July", "August", "September","October", "November", "December"]
    }

    func getNumberOfYears() -> [String]?
    {
        if (numberofYears == nil || numberofYears?.count == 0)
        {
            numberofYears = [String]()
            
            for i in 2016...2040
            {
                numberofYears?.append("\(i)")
            }
        }
        return numberofYears
        
    }
    
     // MARK: - Sorting Filter Methods
    func SortByDay(date : Date) -> [Category]?
    {
        let predicate = NSPredicate(format: "(self.toTransactions.@count != 0) AND (ANY self.toTransactions.expeDate >= %@) AND (ANY self.toTransactions.expeDate <= %@)",date.startOfDay as CVarArg,date.endOfDay as CVarArg)
        
        let result = CoreDataManger.sharedInstance.fetchManageObjects(EntityName: "Category", sortDescriptorKey: "title", isAscending: false, resultPredicate: predicate)
        
        print("Sort by Date:\(date.startOfDay) \(date.endOfDay) \n: %@",result)
        
        return result as? [Category] ?? nil
        
    }
    
    func SortyByMonth(Month : Int, Year : Int) -> [Category]?
    {
        var dateComponents = DateComponents()
        dateComponents.year = Year
        dateComponents.month = Month
        dateComponents.day = 1
        dateComponents.hour = 0
        dateComponents.minute = 0
        dateComponents.timeZone = TimeZone(abbreviation: "UTC")
        let MonthofStartDate = Calendar.current.date(from: dateComponents)
        
        let numberOfDays = Calendar.current.range(of: .day, in: .month, for: MonthofStartDate!)!
        
        dateComponents.year = Year
        dateComponents.month = Month
        dateComponents.day = numberOfDays.count
        dateComponents.hour = 24
        dateComponents.minute = 59
        dateComponents.timeZone = TimeZone(abbreviation: "UTC")
        let MonthofEndDate = Calendar.current.date(from: dateComponents)
        
        let predicate = NSPredicate(format: "(self.toTransactions.@count != 0) AND (ANY self.toTransactions.expeDate >= %@) AND (ANY self.toTransactions.expeDate <= %@)",MonthofStartDate! as CVarArg, MonthofEndDate! as CVarArg)
        
        let result = CoreDataManger.sharedInstance.fetchManageObjects(EntityName: "Category", sortDescriptorKey: "title", isAscending: false, resultPredicate: predicate)
        
        print("Sort by Month : %@",result)
        return result as? [Category] ?? nil
    }
    
    func SortyByYear(Year : Int) -> [Category]?
    {
        var dateComponents = DateComponents()
        dateComponents.year = Year
        dateComponents.month = 1
        dateComponents.day = 1
        dateComponents.hour = 0
        dateComponents.minute = 0
        dateComponents.timeZone = TimeZone(abbreviation: "UTC")
        let MonthofStartDate = Calendar.current.date(from: dateComponents)
        
        dateComponents.year = Year
        dateComponents.month = 12
        dateComponents.day = 31
        dateComponents.hour = 24
        dateComponents.minute = 59
        dateComponents.timeZone = TimeZone(abbreviation: "UTC")
        let MonthofEndDate = Calendar.current.date(from: dateComponents)
        
        let predicate = NSPredicate(format: "(self.toTransactions.@count != 0) AND (ANY self.toTransactions.expeDate >= %@) AND (ANY self.toTransactions.expeDate <= %@)",MonthofStartDate! as CVarArg,MonthofEndDate! as CVarArg)
        
        let result = CoreDataManger.sharedInstance.fetchManageObjects(EntityName: "Category", sortDescriptorKey: "title", isAscending: false, resultPredicate: predicate)
        
        print("Sort by Year : %@",result)
        
        return result as? [Category] ?? nil
    }
    
  
}



extension Date {
    
    var startOfDay : Date {
        let cal = Calendar.current
        var components: DateComponents? = cal.dateComponents([.year, .month, .day, .hour, .minute,.second,], from: self)
        components?.hour = 0
        components?.minute = 0
        components?.second = 0
        components?.timeZone = TimeZone(identifier: "UTC")
        return cal.date(from: components!)!
    }
    
    var endOfDay : Date {
        let cal = Calendar.current
        var components: DateComponents? = cal.dateComponents([.year, .month, .day, .hour, .minute,.second], from: self)
        components?.hour = 23
        components?.minute = 59
        components?.second = 59
        components?.timeZone = TimeZone(identifier: "UTC")
        return cal.date(from: components!)!
    }
    var getMonth : Int{
        let cal = Calendar.current
        let components: DateComponents? = cal.dateComponents([.month], from: self)
        return components?.month ?? 0
    }
    
    var getYear : Int{
        let cal = Calendar.current
        let components: DateComponents? = cal.dateComponents([.year], from: self)
        return components?.year ?? 0
    }
    
    var getUTCDate:Date {
        
        var nowComponents = DateComponents()
        let calendar = Calendar.current
        nowComponents.year = Calendar.current.component(.year, from: self)
        nowComponents.month = Calendar.current.component(.month, from: self)
        nowComponents.day = Calendar.current.component(.day, from: self)
        nowComponents.hour = Calendar.current.component(.hour, from: self)
        nowComponents.minute = Calendar.current.component(.minute, from: self)
        nowComponents.second = Calendar.current.component(.second, from: self)
        nowComponents.timeZone = TimeZone(abbreviation: "UTC")!
        let now = calendar.date(from: nowComponents)!
        return now as Date
    }
    
    
}
