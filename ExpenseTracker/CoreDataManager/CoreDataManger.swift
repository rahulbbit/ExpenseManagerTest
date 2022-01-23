//
//  CoreDataManager.swift
//  ExpenseTracker
//
//  Created by Rahul Patel on 23/01/22.
//

import CoreData

open class CoreDataManger {
	
	// MARK: - Shared Instance
	
	public static let sharedInstance = CoreDataManger()
	
	// MARK: - Initialization
	
	init() {
		NotificationCenter.default.addObserver(self, selector: #selector(contextDidSavePrivateQueueContext(_:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: self.privateQueueCtxt)
		NotificationCenter.default.addObserver(self, selector: #selector(contextDidSaveMainQueueContext(_:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: self.mainQueueCtxt)
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	// MARK: - Notifications
	
	@objc func contextDidSavePrivateQueueContext(_ notification: Notification) {
		if let context = self.mainQueueCtxt {
			self.synced(self, closure: { () -> () in
				context.perform({() -> Void in
					context.mergeChanges(fromContextDidSave: notification)
				})
			})
		}
	}
	
	@objc func contextDidSaveMainQueueContext(_ notification: Notification) {
		if let context = self.privateQueueCtxt {
			self.synced(self, closure: { () -> () in
				context.perform({() -> Void in
					context.mergeChanges(fromContextDidSave: notification)
				})
			})
		}
	}
	
	func synced(_ lock: AnyObject, closure: () -> ()) {
		objc_sync_enter(lock)
		closure()
		objc_sync_exit(lock)
	}
	
	// MARK: - Core Data stack
	
	lazy var applicationDocumentsDirectory: URL = {
		// The directory the application uses to store the Core Data store file. This code uses a directory named 'Bundle identifier' in the application's documents Application Support directory.
		let urls = Foundation.FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		return urls[urls.count-1]
	}()
	
	lazy var managedObjectModel: NSManagedObjectModel = {
		// The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
		let modelURL = Bundle.main.url(forResource: "ExpenseTracker", withExtension: "momd")!
		return NSManagedObjectModel(contentsOf: modelURL)!
	}()
    
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        let fileManager = FileManager.default
        let storeName = "ExpenseTracker.sqlite"
        
        let documentsDirectoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        let persistentStoreURL = documentsDirectoryURL.appendingPathComponent(storeName)
        
        do {
            try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                                              configurationName: nil,
                                                              at: persistentStoreURL,
                                                              options: [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true])
        } catch
        {
            fatalError("Unable to Load Persistent Store")
        }
        
        return persistentStoreCoordinator
    }()
	
	
	// MARK: - NSManagedObject Contexts
	
	open class func mainQueueContext() -> NSManagedObjectContext {
		return self.sharedInstance.mainQueueCtxt!
	}
	
	open class func privateQueueContext() -> NSManagedObjectContext {
		return self.sharedInstance.privateQueueCtxt!
	}
	
	lazy var mainQueueCtxt: NSManagedObjectContext? = {
		// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
		var managedObjectContext = NSManagedObjectContext(concurrencyType:.mainQueueConcurrencyType)
		managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
		return managedObjectContext
	}()
	
	lazy var privateQueueCtxt: NSManagedObjectContext? = {
		// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
		var managedObjectContext = NSManagedObjectContext(concurrencyType:.privateQueueConcurrencyType)
		managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
		return managedObjectContext
	}()
	
	// MARK: - Core Data Saving support
	
	open class func saveContext(_ context: NSManagedObjectContext?) {
		if let moc = context {
			if moc.hasChanges {
				do {
					try moc.save()
				} catch {
				}
			}
		}
	}
    
    
    //MARK: Custom Methods
    
    func getContext () -> NSManagedObjectContext {
        let context = self.mainQueueCtxt
        return context!
    }
    
    func fetchAllManageObjects(EntityName:String,sortDescriptorKey : String?, isAscending : Bool, fetchLimit : Bool) -> NSArray {
        
        // Initialize Fetch Request
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        
        let managedObjectContext = self.getContext()
        
        // Create Entity Description
        let entityDescription = NSEntityDescription.entity(forEntityName: EntityName, in: managedObjectContext)
        
        if sortDescriptorKey != nil{
           let sectionSortDescriptor = NSSortDescriptor(key: sortDescriptorKey, ascending: isAscending)
            let sortDescriptors = [sectionSortDescriptor]
            fetchRequest.sortDescriptors = sortDescriptors
        }
        
        
        if fetchLimit {
            fetchRequest.fetchLimit = 2
        }
        
        // Configure Fetch Request
        fetchRequest.entity = entityDescription
        var resultAry : NSArray!
        
        do {
            resultAry = try managedObjectContext.fetch(fetchRequest) as NSArray
            
        } catch {
            
            let fetchError = error as NSError
            print(fetchError)
        }
        
        return resultAry
        
    }
    
    func fetchManageObjects(EntityName:String,sortDescriptorKey : String, isAscending : Bool, resultPredicate : NSPredicate?) -> NSArray {
        
        // Initialize Fetch Request
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        
        let managedObjectContext = self.getContext()
        
        // Create Entity Description
        let entityDescription = NSEntityDescription.entity(forEntityName: EntityName, in: managedObjectContext)
        
        let sectionSortDescriptor = NSSortDescriptor(key: sortDescriptorKey, ascending: isAscending)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        // Create predicate //
        fetchRequest.predicate = resultPredicate
        
        // Configure Fetch Request
        fetchRequest.entity = entityDescription
        var resultAry : NSArray!
        
        do {
            resultAry = try managedObjectContext.fetch(fetchRequest) as NSArray
            
        } catch {
            
            let fetchError = error as NSError
            print(fetchError)
        }
        
        return resultAry
        
    }
    
    
    func saveContext () {
        let context = self.getContext()
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

	
}

extension NSManagedObject {
	
	public class func findAllForEntity(_ entityName: String, context: NSManagedObjectContext) -> [AnyObject]? {
		let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
		let result: [AnyObject]?
		do {
			result = try context.fetch(request)
		} catch let error as NSError {
			print(error)
			result = nil
		}
		return result
	}
	
}


extension NSManagedObjectContext
{
    func deleteAllData()
    {
        guard let persistentStore = persistentStoreCoordinator?.persistentStores.last else {
            return
        }
        
        guard let url = persistentStoreCoordinator?.url(for: persistentStore) else {
            return
        }
        performAndWait { () -> Void in
            self.reset()
            do
            {
                try self.persistentStoreCoordinator?.remove(persistentStore)
                try FileManager.default.removeItem(at: url)
                try self.persistentStoreCoordinator?.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
            }
            catch
            {
                print("ERROR")
                /*dealing with errors up to the usage*/
            }
        }
    }
}

