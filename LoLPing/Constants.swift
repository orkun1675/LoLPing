//
//  Constants.swift
//  LoLPing
//
//  Created by Orkun Duman on 30/10/2016.
//  Copyright © 2016 OBD. All rights reserved.
//

import Foundation

struct Constants {
    
    static let SERVER_LIST: [String: String] = [ "NA": "104.160.131.3",
                                                 "EUW": "104.160.141.3",
                                                 "EUNE": "104.160.142.3",
                                                 "OCE": "104.160.156.1",
                                                 "LAN": "104.160.136.3",
                                                 "BR": "104.160.152.3"]
    static var AVARAGE_PING_COUNT = 3
    static var PING_TIMEOUT_MS = 5000
    static var MENU_IMAGE_SIZE_RATIO: CGFloat = 1.5
    static var GOOD_SIGNAL_LIMIT_MS = 90
    static var OKAY_SIGNAL_LIMIT_MS = 165
    static var BAD_SIGNAL_LIMIT_MS = 280
    
    struct UserData {
        static let ACTIVE_SERVER_KEY = "SelectedGameServer"
        static var ACTIVE_SERVER = "NA"
        
        static func save() {
            let defaults = UserDefaults.standard
            defaults.setValue(ACTIVE_SERVER, forKey: ACTIVE_SERVER_KEY)
            defaults.synchronize()
        }
        
        static func load() {
            let defaults = UserDefaults.standard
            if let activeServer = defaults.string(forKey: ACTIVE_SERVER_KEY) {
                ACTIVE_SERVER = activeServer
            }
        }
    }
    
}
