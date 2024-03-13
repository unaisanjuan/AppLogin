//
//  ContentView.swift
//  LoginApp
//
//  Created by  on 11/3/24.
//

import SwiftUI

struct ContentView: View {
    @State private var isRegistrationSuccess = false // Definir isRegistrationSuccess en ContentView
    
    var body: some View {
        TabView {
            LoginView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Iniciar sesión")
                }
            RegisterView(isRegistrationSuccess: $isRegistrationSuccess)
                .tabItem {
                    Image(systemName: "person.badge.plus.fill")
                    Text("Registro")
                }
        }
        .onChange(of: isRegistrationSuccess) { success in
            if success {
                DispatchQueue.main.async {
                    self.isRegistrationSuccess = false
                }
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
