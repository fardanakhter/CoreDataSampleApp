//
//  CDAdminModel.swift
//  HandsOnCoreData
//
//  Created by Fardan Akhter on 8/18/21.
//

import Foundation
import CoreData

final class CDAdminModel: CDModel{
    //Coredata NSManagedObject Properties
    @NSManaged var email: String?
    @NSManaged var fullName: String?
    
    enum CodingKeys: String, CodingKey{
        case email
        case fullName
    }
    
    // MARK:- Init Entity
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {

        guard let _ = context,
              let admin = NSEntityDescription.entity(forEntityName: CoreDataEntity.admin.rawValue,
                                                          in: context!)
        else{
            fatalError("Failed to decode entity")
        }
        super.init(entity: admin, insertInto: context)
    }
    
    // MARK:- Decodable
    override func decode(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.email = try container.decodeIfPresent(String.self, forKey: .email) ?? ""
        self.fullName = try container.decodeIfPresent(String.self, forKey: .fullName) ?? ""
    }
    
    // MARK: - Encodable
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(email, forKey: .email)
        try container.encode(fullName, forKey: .fullName)
    }
}

