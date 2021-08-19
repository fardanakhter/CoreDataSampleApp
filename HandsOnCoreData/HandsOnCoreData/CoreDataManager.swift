//
//  CoreDataManager.swift
//  HandsOnCoreData
//
//  Created by Fardan Akhter on 8/18/21.
//

import Foundation
import CoreData
import UIKit

public extension CodingUserInfoKey {
    // Helper property to retrieve the context
    // This is to store context for first hand access to context, instead of explicitly passing into object
    static let managedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext")
}

// This is for saving NSManagedObjectContext with in Codable Object instead of explicitly passing
enum CoreDataEntity: String {
    case user = "User"
    case admin = "Admin"
    case none
    
    func entityDescription(context: NSManagedObjectContext) -> NSEntityDescription?{
        return NSEntityDescription.entity(forEntityName: self.rawValue, in: context)
    }
}

protocol CDModelProtocol: DatabaseModelProtocol, Codable {}

// This model support Json to/from Coredata parsing
// Here NSManagedObject is like row of a Table(Entity)
class CDModel: NSManagedObject, CDModelProtocol{
    
    required convenience init(from decoder: Decoder) throws {
        guard let codingUserInfoKeyManagedObjectContext = CodingUserInfoKey.managedObjectContext,
              let managedObjectContext = decoder.userInfo[codingUserInfoKeyManagedObjectContext] as? NSManagedObjectContext
              //,let entity = NSEntityDescription.entity(forEntityName: CoreDataEntity.none.rawValue, in: managedObjectContext)
        else {
            fatalError("Failed to decode entity!")
        }
        self.init(entity: NSEntityDescription(), insertInto: managedObjectContext)
        try self.decode(from: decoder)
    }
    
    // MARK: - Decodable
    public func decode(from decoder: Decoder) throws {
    }
    
    // MARK: - Encodable
    public func encode(to encoder: Encoder) throws {}
}

class CDManager: DatabaseManager{
    typealias T = CDModel
    
    var context: NSManagedObjectContext!
    var persistentContainer: NSPersistentContainer!
    var enityType: CoreDataEntity = .none
    
    init(entity: CoreDataEntity) {
        enityType = entity
        setupDatabase()
    }
    
    func saveContext(){
        do {
            try context.save()
        } catch  {
            print("failed to save context!")
        }
    }
    
    func setupDatabase() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.persistentContainer = appDelegate.persistentContainer
        self.context = persistentContainer.viewContext
    }
    
    func addDatabaseModel(model: CDModel) {
        context.insert(model)
        saveContext()
    }
    
    func fetchDatabaseModels() -> [CDModel] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: enityType.rawValue)
        //let containsPredicate = NSPredicate(format: "email CONTAINS[c] 'test'") // [c] matches with case insensitive
        //let matchesPredicate = NSPredicate(format: "first_name =%@", "test")
        //fetchRequest.predicate = matchesPredicate
        if let results = try? context.fetch(fetchRequest) as? [CDModel]{
            return results
        }
        return []
    }
    
    func deleteDatabaseModel(model: CDModel) {
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: enityType.rawValue)
//        let matchesPredicate = NSPredicate(format: "objectID =%@", "\(model.objectID)")
//        fetchRequest.predicate = matchesPredicate
//        if let objects = try? context.fetch(fetchRequest) as? [CDModel]{
//
//            objects.forEach{ obj in
//                context.delete(obj)
//            }
//        }
        context.delete(model)
        saveContext()
    }
    
    func deleteAll() {
        // Specify a batch to delete with a fetch request
        let fetchRequest: NSFetchRequest<NSFetchRequestResult>
        fetchRequest = NSFetchRequest(entityName: enityType.rawValue)
        
        // Create a batch delete request for the
        // fetch request
        let deleteRequest = NSBatchDeleteRequest(
            fetchRequest: fetchRequest
        )
        
        // Specify the result of the NSBatchDeleteRequest
        // should be the NSManagedObject IDs for the
        // deleted objects
        deleteRequest.resultType = .resultTypeObjectIDs
        
        // Get a reference to a managed object context
        let context = persistentContainer.viewContext
        
        // Perform the batch delete
        let batchDelete = try! context.execute(deleteRequest)
            as? NSBatchDeleteResult
        
        guard let deleteResult = batchDelete?.result
                as? [NSManagedObjectID]
        else { return }
        
        let deletedObjects: [AnyHashable: Any] = [
            NSDeletedObjectsKey: deleteResult
        ]
        
        // Merge the delete changes into the managed
        // object context
        NSManagedObjectContext.mergeChanges(
            fromRemoteContextSave: deletedObjects,
            into: [context]
        )
    }
}




