//
//  Config.swift
//  Contract Whist Scorecard
//
//  Created by Marc Shearer on 25/09/2017.
//  Copyright © 2017 Marc Shearer. All rights reserved.
//

import Foundation

class Config {
    
    // iCloud database identifer
    public static let iCloudIdentifier = "iCloud.MarcShearer.Wots4T"

    // Columns for record IDs
    public static let recordIdKeys: [String:[String]] = [:]
    
    public static let backupDirectoryDateFormat = "yyyy-MM-dd-HH-mm-ss-SSS"
    public static let backupDateFormat = "yyyy-MM-dd HH:mm:ss.SSS Z"
    public static let recordIdDateFormat = "yyyy-MM-dd-HH-mm-ss"
}

