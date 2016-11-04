# LoLPing
OS X Menu Bar App to Test Ping to LoL Servers

This is a simple menu-bar application for Mac OS X devices (10.10+) that let's the user select which League of Legends server they are playing on, and shows them their current ping (delay) to this server.

## Pinging
The ICMP protocol is used to send and receive data to remote servers. The project implements the [SimplePing API by Apple](https://developer.apple.com/library/content/samplecode/SimplePing/Introduction/Intro.html) to ease the process.

## Startup
The application is run automaticaly at startup (whenever the user logs in). This is achieved by the *LauncherHelper* application embeded in the project. *LauncherHelper* is registered as login item, and launches *LoLPing* when it is run. *LoLPing* terminates *LauncherHelper* once it initializes properly.

## UserData
The user data (which server the user selected) is stored in the *UserDefaults.standard* library.
