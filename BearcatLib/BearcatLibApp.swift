//
//  BearcatLibApp.swift
//  BearcatLib
//
//  Created by Joseph Musenge on 2/15/26.
//

import SwiftUI

@main
struct BearcatLibApp: App {
    @StateObject private var settings = AppSettings()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
            .environmentObject(settings)
            .preferredColorScheme(settings.isDarkMode ? .dark : .light)
        }
    }
}
