//
//  AlarmGroupsApp.swift
//  AlarmGroups
//
//  Created by Josh Boynton on 11/11/24.
//

import SwiftUI

@main
struct AlarmGroupsApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
