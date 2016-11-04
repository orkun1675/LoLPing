//
//  PingRecorder.swift
//  LoLPing
//
//  Created by Orkun Duman on 30/10/2016.
//  Copyright © 2016 OBD. All rights reserved.
//

import Foundation
import Cocoa

class PingRecorder {
    
    var statusBarItem: NSStatusItem
    var pingDisplay: NSMenuItem
    
    var pingList: [Int]
    var pingerInstance: PingAPIHook? = nil
    
    var pingerPaused = false
    
    init(statusBarItem: NSStatusItem, pingDisplay: NSMenuItem) {
        self.statusBarItem = statusBarItem
        self.pingDisplay = pingDisplay
        pingList = []
    }
    
    func serverUpdated() {
        pingerPaused = false
        statusBarItem.title = "??ms"
        if let button = statusBarItem.button {
            button.appearsDisabled = false
        }
        pingDisplay.title = "Pinging server..."
        pingDisplay.image = nil
        pingList.removeAll()
        if (pingerInstance != nil) {
            pingerInstance?.terminate()
        }
        pingerInstance = PingAPIHook(recorder: self, hostName: Constants.SERVER_LIST[Constants.UserData.ACTIVE_SERVER]!)
    }
    
    func paused() {
        pingerPaused = true
        statusBarItem.title = ""
        if let button = statusBarItem.button {
            button.appearsDisabled = false
        }
        pingList.removeAll()
        if (pingerInstance != nil) {
            pingerInstance?.terminate()
        }
        pingDisplay.title = "Pinger is paused."
        pingDisplay.image = getImage(ping: -1)
        pingDisplay.menu?.update()
    }
    
    func lostConnection() {
        if pingerPaused {
            return
        }
        statusBarItem.title = "??ms"
        pingList.removeAll()
        if let button = statusBarItem.button {
            button.appearsDisabled = true
        }
        pingDisplay.title = "Can't connect to server!"
        pingDisplay.image = getImage(ping: -1)
        pingDisplay.menu?.update()
    }
    
    func pingReceived(delay: Int) {
        if pingerPaused {
            return
        }
        if let button = statusBarItem.button {
            button.appearsDisabled = false
        }
        if (pingList.count >= Constants.AVARAGE_PING_COUNT) {
            pingList.removeFirst()
        }
        pingList.append(delay)
        var ping = 0
        for i in pingList {
            ping = ping + i
        }
        ping = ping / pingList.count
        pingDisplay.title = "Current Ping (\(Constants.UserData.ACTIVE_SERVER)) : \(ping)"
        pingDisplay.image = getImage(ping: ping)
        pingDisplay.menu?.update()
        if (ping < Constants.PING_TIMEOUT_MS) {
            statusBarItem.title = "\(ping)ms"
        } else {
            statusBarItem.title = "??ms"
        }
    }
    
    private func getImage(ping: Int) -> NSImage {
        var size = NSSize()
        size.height = NSFont.menuFont(ofSize: 0).pointSize;
        size.width = size.height * Constants.MENU_IMAGE_SIZE_RATIO;
        var image: NSImage
        if (ping < 0) {
            image = NSImage(named: "MenuItemPingImage0")!
        } else if (ping < Constants.GOOD_SIGNAL_LIMIT_MS) {
            image = NSImage(named: "MenuItemPingImage4")!
        } else if (ping < Constants.OKAY_SIGNAL_LIMIT_MS) {
            image = NSImage(named: "MenuItemPingImage3")!
        } else if (ping < Constants.BAD_SIGNAL_LIMIT_MS) {
            image = NSImage(named: "MenuItemPingImage2")!
        } else {
            image = NSImage(named: "MenuItemPingImage1")!
        }
        image.size = size
        return image
    }
    
}
