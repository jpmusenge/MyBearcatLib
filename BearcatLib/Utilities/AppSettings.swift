//
//  Appsettings.swift
//  BearcatLib
//
//  Created by Joseph Musenge on 3/1/26.
//

// PURPOSE: A shared settings object that any view can read/write

import SwiftUI
import Combine

class AppSettings: ObservableObject {
    
    // @AppStorage persists this value between app launches automatically
    @AppStorage("isDarkMode") var isDarkMode: Bool = false {
        didSet {
            // This tells SwiftUI to re-render any view watching this object
            objectWillChange.send()
        }
    }
}
