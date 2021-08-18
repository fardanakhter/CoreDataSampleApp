//
//  DatabaseManager.swift
//  HandsOnCoreData
//
//  Created by Fardan Akhter on 8/18/21.
//

import Foundation

protocol DatabaseModelProtocol{}

protocol DatabaseManager{
    
    associatedtype T: DatabaseModelProtocol
    
    //define CRUD functions here
    
    //Setup Code
    func setupDatabase()
    //func createDatabaseSchema()
    
    //Create
    func addDatabaseModel(model: T)
    
    //Update
    //func updateDatabaseModel(model: T)
    
    //Delete
    func deleteDatabaseModel(model: T)
    func deleteAll()
    
    //Read
    func fetchDatabaseModels() -> [T]
}
