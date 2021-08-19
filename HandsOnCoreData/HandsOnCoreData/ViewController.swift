//
//  ViewController.swift
//  HandsOnCoreData
//
//  Created by Fardan Akhter on 8/18/21.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet weak var firstname: UITextField!
    @IBOutlet weak var lastname: UITextField!
    @IBOutlet weak var emailAddress: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //parsableJson()
        
        //let entity: CoreDataEntity = .user
        //let modelType = (entity == .user ? CDUserModel.self : CDAdminModel.self)
        //let manager = CDManager(entity: entity)
        
        
        //        let user = CDUserModel(context: manager.context)
        //        user.firstName = "test"
        //        user.lastName = "test"
        //        user.setValue("john", forKey: CDUserModel.CodingKeys.firstName.rawValue)
        //        user.setValue("cena", forKey: CDUserModel.CodingKeys.lastName.rawValue)
        
        //        manager.addDatabaseModel(model: user)
        
        //        if let models = manager.fetchDatabaseModels() as? [CDUserModel]{
        //            models.forEach{ item in
        //                print("\(item.firstName ?? "") \(item.lastName ?? "" )")
        //            }
        //
        //            let fetchedModel = models.first!
        //            manager.deleteDatabaseModel(model: fetchedModel)
        
        //            fetchedModel?.firstName = "johnny"
        //            manager.saveContext()
        //
        //            models.forEach{ item in
        //                print("\(item.firstName ?? "") \(item.lastName ?? "" )")
        //            }
        //    }
        //manager.deleteAll()
        
        retrieveValuesToViews()
    }
    
    func retrieveValuesToViews(){
        let userManager = CDManager(entity: .user)
        let user = userManager.fetchDatabaseModels()
        guard let userObj = user.last as? CDUserModel else {return}
        self.firstname.text = userObj.firstName
        self.lastname.text = userObj.lastName
        
        let adminManager = CDManager(entity: .admin)
        let admin = adminManager.fetchDatabaseModels()
        guard let adminObj = admin.last as? CDAdminModel else {return}
        self.emailAddress.text = adminObj.email
    }
    
    // MARK:- This is for parsing sample json into Codable + NSManagedObject Model
    func parsableJson(){
        
        let jsonData = """
    {
    "firstName" : "test first",
    "lastName" : "test last"
    }
    """.data(using: .utf8)!
        
        let jsonData02 = """
    {
    "email" : "test@work.com",
    "fullName" : "admin user"
    }
    """.data(using: .utf8)!
        
        guard let codingUserInfoKeyManagedObjectContext = CodingUserInfoKey.managedObjectContext else {
            fatalError("Failed to retrieve context")
        }
        
        // Clear storage and save managed object instances
        //            if currentPage == 0 {
        //                clearStorage()
        //            }
        
        // Parse JSON data
        let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let decoder = JSONDecoder()
        decoder.userInfo[codingUserInfoKeyManagedObjectContext] = managedObjectContext
        
        let user = try! decoder.decode(CDUserModel.self, from: jsonData)
        
        let admin = try! decoder.decode(CDAdminModel.self, from: jsonData02)
        
        try! managedObjectContext.save()
    }
    
    @IBAction func saveAction(_ sender: Any) {
        
        let userManager = CDManager(entity: .user)
        userManager.deleteAll()
        let user = CDUserModel(context: userManager.context)
        user.firstName = firstname.text ?? ""
        user.lastName = lastname.text ?? ""
        userManager.addDatabaseModel(model: user)
        
        let adminManager = CDManager(entity: .admin)
        adminManager.deleteAll()
        let admin = CDAdminModel(context: adminManager.context)
        admin.email = emailAddress.text ?? ""
        adminManager.addDatabaseModel(model: admin)
    }
}


//CRUD Operations
/*
 func insertCoredata(){
 // 1 - get Context
 let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
 let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
 
 // 2 - get entity from context
 guard let entity = NSEntityDescription.entity(forEntityName: "UserEntity", in: context) else {
 print("failed to find an entity!")
 return
 }
 
 // 3 - set propertu values to entity
 let userEntiry: NSManagedObject = NSManagedObject(entity: entity, insertInto: context)
 userEntiry.setValue("test", forKey: "first_name")
 userEntiry.setValue("test", forKey: "last_name")
 userEntiry.setValue("74600", forKey: "postal_code")
 userEntiry.setValue("fardan@hotmail.com", forKey: "email")
 
 //4 - insert entity into context
 context.insert(userEntiry)
 
 // 5 - save context
 do {
 try context.save()
 }
 catch{
 print("failed to save context!")
 }
 }
 
 func getCoreData(entity: CoreDataEntity) -> [NSManagedObject]? {
 
 // 1 = context
 let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
 let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
 
 let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity.rawValue)
 //let containsPredicate = NSPredicate(format: "email CONTAINS[c] 'test'") // [c] matches with case insensitive
 //let matchesPredicate = NSPredicate(format: "first_name =%@", "test")
 //fetchRequest.predicate = matchesPredicate
 
 if let results = try? context.fetch(fetchRequest) as? [NSManagedObject]{
 
 results.forEach{ item in
 print("-------------------------------------------")
 print(item.value(forKey: "firstName") as? String ?? "")
 print(item.value(forKey: "lastName") as? String ?? "")
 print("-------------------------------------------")
 }
 
 return results
 }
 return nil
 }
 
 func updateCoreData(){
 // 1 = context
 let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
 let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
 
 let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserEntity")
 let containsPredicate = NSPredicate(format: "email CONTAINS[c] 'test'") // [c] matches with case insensitive
 let matchesPredicate = NSPredicate(format: "first_name =%@", "fardan")
 
 fetchRequest.predicate = matchesPredicate
 
 if let results = try? context.fetch(fetchRequest) as? [NSManagedObject],
 let searched = results.first{
 searched.setValue("farda", forKey: "first_name")
 
 do {
 try context.save()
 } catch  {
 print("failed to save context!")
 }
 
 }
 }
 
 func deleteCoredata(){
 
 let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
 let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
 
 let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserEntity")
 
 if let objects = try? context.fetch(fetchRequest) as? [NSManagedObject]{
 
 objects.forEach{ obj in
 context.delete(obj)
 }
 }
 
 do {
 try context.save()
 } catch  {
 print("failed to save!")
 }
 }
 */
