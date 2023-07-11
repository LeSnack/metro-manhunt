//
//  Metro_ManhuntApp.swift
//  Metro_Manhunt
//
//  Created by Zac Whales on 2/5/2023.
//

import SwiftUI

@main
struct Metro_ManhuntApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
            .environmentObject(WebRTCManager())
        }
    }
}
