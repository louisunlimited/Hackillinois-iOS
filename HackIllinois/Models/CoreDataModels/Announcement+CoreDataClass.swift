//
//  Announcement+CoreDataClass.swift
//  HackIllinois
//
//  Created by Rauhul Varma on 11/20/17.
//  Copyright © 2017 HackIllinois. All rights reserved.
//  This file is part of the Hackillinois iOS App.
//  The Hackillinois iOS App is open source software, released under the University of
//  Illinois/NCSA Open Source License. You should have received a copy of
//  this license in a file with the distribution.
//

import Foundation
import CoreData
import HIAPI

@objc(Announcement)
public class Announcement: NSManagedObject {
    convenience init(context moc: NSManagedObjectContext, announcement: HIAPI.Announcement) {
        guard let entity = NSEntityDescription.entity(forEntityName: "Announcement", in: moc) else { fatalError() }
        self.init(entity: entity, insertInto: moc)
        id = announcement.id
        info = announcement.info
        title = announcement.title
        time = announcement.time
    }
}
