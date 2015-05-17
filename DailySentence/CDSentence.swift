//
//  CDSentence.swift
//  DailySentence
//
//  Created by Chen Hsin Hsuan on 2015/5/14.
//  Copyright (c) 2015年 AirconTW. All rights reserved.
//

import Foundation
import CoreData

class CDSentence: NSManagedObject {

    @NSManaged var author: String
    @NSManaged var cn: String
    @NSManaged var createat: String
    @NSManaged var en: String
    @NSManaged var id: String
    @NSManaged var url: String
    @NSManaged var favormk: NSNumber

}
