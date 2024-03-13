//
//  LoginAppApp.swift
//  LoginApp
//
//  Created by  on 11/3/24.
//

import SwiftUI
import FirebaseCore

@main
struct LoginAppApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        
    
        WindowGroup {
            ContentView()
        }
    }
}
