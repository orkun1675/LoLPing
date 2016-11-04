//
//  PingAPIHook.swift
//  LoLPing
//
//  Created by Orkun Duman on 30/10/2016.
//  Copyright © 2016 OBD. All rights reserved.
//

import Foundation
import Cocoa

class PingAPIHook : NSObject, SimplePingDelegate {
    
    var recorder: PingRecorder
    
    var timer: Timer!
    var pinger: SimplePing? = nil
    
    var sentPings: [UInt16 : Int64] = [:]
    var enabled = false
    
    var failCount = 0
    
    init(recorder: PingRecorder, hostName: String) {
        self.recorder = recorder
        super.init()
        if (pinger != nil) {
            self.pinger?.stop()
        }
        pinger = nil
        let newPinger = SimplePing(hostName: hostName)
        pinger = newPinger
        newPinger.delegate = self
        newPinger.start()
        enabled = true
    }
    
    func terminate() {
        enabled = false
        timer.invalidate()
        if (pinger != nil) {
            pinger?.stop()
        }
    }
    
    @objc func pingServer(sender: AnyObject?) {
        if (pinger == nil) {
            return
        }
        sentPings[pinger!.nextSequenceNumber] = Int64(Date().timeIntervalSince1970 * 1000)
        pinger!.send(with: nil)
    }
    
    func simplePing(_ pinger: SimplePing, didStartWithAddress address: Data) {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(PingAPIHook.pingServer), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: .commonModes)
    }
    
    func simplePing(_ pinger: SimplePing, didFailWithError error: Error) {
        NSLog("\(error)")
    }
    
    func simplePing(_ pinger: SimplePing, didFailToSendPacket packet: Data, sequenceNumber: UInt16, error: Error) {
        failCount = failCount + 1
        if failCount >= 3 {
            recorder.lostConnection()
        }
        sentPings.removeValue(forKey: sequenceNumber)
        clearOldPings()
    }
    
    func simplePing(_ pinger: SimplePing, didReceivePingResponsePacket packet: Data, sequenceNumber: UInt16) {
        let sentAt = sentPings.removeValue(forKey: sequenceNumber)
        if (sentAt == nil) {
            return
        }
        let receivedAt = Int64(Date().timeIntervalSince1970 * 1000)
        if (enabled) {
            recorder.pingReceived(delay: Int(receivedAt - sentAt!))
        }
        clearOldPings()
    }
    
    private func clearOldPings() {
        let currentTime = Int64(Date().timeIntervalSince1970 * 1000)
        for key in sentPings.keys {
            if (sentPings[key]! < (currentTime - Constants.PING_TIMEOUT_MS)) {
                sentPings.removeValue(forKey: key)
            }
        }
    }
    
}
