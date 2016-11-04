//
//  AppDelegate.swift
//  LoLPing
//
//  Created by Orkun Duman on 29/10/2016.
//  Copyright © 2016 OBD. All rights reserved.
//

import Cocoa
import ServiceManagement

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    let serverMenu = NSMenu()
    var pingRecorder : PingRecorder? = nil
    var pauseMenuItem = NSMenuItem()
    var isPaused = false

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        killHelperApp()
        Constants.UserData.load()
        
        if let button = statusItem.button {
            button.image = NSImage(named: "StatusBarButtonImage")
        }
        
        let menu = NSMenu()
        let changeServerMenu = NSMenuItem(title: "Change Server", action: nil, keyEquivalent: "")
        changeServerMenu.submenu = createServerMenu()
        let pingMenuItem = NSMenuItem(title: "Pinging server...", action: #selector(AppDelegate.doNothing), keyEquivalent: "")
        pauseMenuItem = NSMenuItem(title: "Pause Pinger", action: #selector(AppDelegate.pause), keyEquivalent: "")
        
        menu.addItem(pingMenuItem)
        menu.addItem(changeServerMenu)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(pauseMenuItem)
        menu.addItem(NSMenuItem(title: "Quit LoLPing", action: #selector(AppDelegate.terminate), keyEquivalent: ""))
        
        statusItem.menu = menu
        statusItem.title = "62ms"
        
        pingRecorder = PingRecorder(statusBarItem: statusItem, pingDisplay: pingMenuItem)
        pingRecorder?.serverUpdated()
    }
    
    func killHelperApp() {
        let launcherHelperAppIdentifier = "me.duman.LauncherHelper"
        SMLoginItemSetEnabled(launcherHelperAppIdentifier as CFString, true)
        var startedAtLogin = false
        for app in NSWorkspace.shared().runningApplications {
            if app.bundleIdentifier == launcherHelperAppIdentifier {
                startedAtLogin = true
                break
            }
        }
        if startedAtLogin {
            DistributedNotificationCenter.default().postNotificationName(NSNotification.Name(rawValue: "killme"), object: Bundle.main.bundleIdentifier!)
        }
    }

    func createServerMenu() -> NSMenu {
        for serverName in Constants.SERVER_LIST.keys.sorted() {
            let menuItem = NSMenuItem(title: serverName, action: #selector(AppDelegate.serverChanged), keyEquivalent: "")
            if (serverName == Constants.UserData.ACTIVE_SERVER) {
                menuItem.state = NSOnState
            }
            serverMenu.addItem(menuItem)
        }
        return serverMenu
    }
    
    func serverChanged(sender: AnyObject) {
        let clickedItem = sender as! NSMenuItem
        Constants.UserData.ACTIVE_SERVER = clickedItem.title
        Constants.UserData.save()
        for menuItem in serverMenu.items {
            if (menuItem.title == Constants.UserData.ACTIVE_SERVER) {
                menuItem.state = NSOnState
            }
            else {
                menuItem.state = NSOffState
            }
        }
        if isPaused {
            pause()
        } else {
            pingRecorder?.serverUpdated()
        }
    }
    
    func doNothing() {
        //The action event cannot be nil. This is a work-around.
    }
    
    func pause() {
        if isPaused {
            pingRecorder?.serverUpdated()
            pauseMenuItem.title = "Pause Pinging"
        } else {
            pingRecorder?.paused()
            pauseMenuItem.title = "Resume Pinging"
        }
        isPaused = !isPaused
    }
    
    func terminate() {
        NSApplication.shared().terminate(self)
    }

}

