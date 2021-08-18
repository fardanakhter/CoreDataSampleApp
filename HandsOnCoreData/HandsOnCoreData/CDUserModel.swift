//
//  CDUserModel.swift
//  HandsOnCoreData
//
//  Created by Fardan Akhter on 8/18/21.
//

import Foundation
import CoreData

final class CDUserModel: CDModel{
    //Coredata NSManagedObject Properties
    @NSManaged var firstName: String?
    @NSManaged var lastName: String?
    
    enum CodingKeys: String, CodingKey{
        case firstName
        case lastName
    }
    
    // MARK:- Init Entity
    private override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {

        guard let _ = context,
              let userEntity = NSEntityDescription.entity(forEntityName: CoreDataEntity.user.rawValue,
                                                          in: context!)
        else{
            fatalError("Failed to decode entity")
        }
        super.init(entity: userEntity, insertInto: context)
    }
    
    // MARK:- Decodable
    override func decode(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.firstName = try container.decodeIfPresent(String.self, forKey: .firstName) ?? ""
        self.lastName = try container.decodeIfPresent(String.self, forKey: .lastName) ?? ""
    }
    
    // MARK: - Encodable
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
    }
}
