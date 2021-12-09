//
//  MiBandData+CoreDataProperties.swift
//  MibandDataCollector
//
//  Created by Lehel Dénes-Fazakas on 2021. 12. 09..
//
//

import Foundation
import CoreData


extension MiBandData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MiBandData> {
        return NSFetchRequest<MiBandData>(entityName: "MiBandData")
    }

    @NSManaged public var sensor: String?
    @NSManaged public var value: String?
    @NSManaged public var userid: String?
    @NSManaged public var timestamp: Int64

}

extension MiBandData : Identifiable {

}
