//
//  Version.swift
//  Contract Whist Scorecard
//
//  Created by Marc Shearer on 08/05/2020.
//  Copyright © 2020 Marc Shearer. All rights reserved.
//

import Foundation

class Version {
    
    static private(set) var current = Version()
    
    public var version = "0.0"
    public var build = 0
    public var lastVersion = "0.0"
    public var lastBuild = 0
    public var minVersion = ""
    public var minMessage = ""
    public var infoMessage = ""
    
    init() {
        // Set up current version and build
        let dictionary = Bundle.main.infoDictionary!
        self.version = dictionary["CFBundleShortVersionString"] as! String? ?? "0.0"
        self.build = Int(dictionary["CFBundleVersion"] as! String) ?? 0
        
        // Get previous version, build etc
        self.lastVersion = UserDefault.lastVersion.string
        self.lastBuild = UserDefault.lastBuild.int
        self.minVersion = UserDefault.minVersion.string
        self.minMessage = UserDefault.minMessage.string
        self.infoMessage = UserDefault.infoMessage.string
        
        if Double(self.lastVersion) == 0.0 {
            // New install - just use current version
            self.acceptVersion()
        } else if compare(self.lastVersion, self.version) == .lessThan {
            // Version has increased - check for upgrade
            self.upgradeToVersion()
        }
    }
    
    private func upgradeToVersion() {
        if compare(self.lastVersion, "1.0") == .lessThan {
            // Upgrade to version 1.0
        }
    }
    
    private func acceptVersion() {
        UserDefault.lastVersion.set(self.version)
        UserDefault.lastVersion.set(self.build)
    }
    
    private func compare(_ version1: String, _ version2: String) -> Utility.CompareResult {
        return Utility.compareVersions(version1: version1, version2: version2)
    }
}
