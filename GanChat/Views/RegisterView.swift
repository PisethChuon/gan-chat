//
//  RegisterView.swift
//  GanChat
//
//  Created by chuonpiseth on 7/9/26.
//

import SwiftUI

struct RegisterView: View {
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    
    var body: some View {
        VStack {
            Text("Welcome")
                .font(.title)
                .bold()
            
            Text("Register with your email and password.")
            
            TextField("Username", text: $username)
                .textFieldStyle(.roundedBorder)
            
            TextField("Email", text: $email)
                .textFieldStyle(.roundedBorder)
            
            TextField("Password", text: $password)
                .textFieldStyle(.roundedBorder)
            
            TextField("Confirm Password", text: $confirmPassword)
                .textFieldStyle(.roundedBorder)
            
            Button("Register") {
                register()
            }
            .padding(.top)
            .buttonStyle(.bordered)
        }
        .padding()
    }
    
    func register() {
        print("username: \(username) | email: \(email) | password: \(password) | confirmPassword: \(confirmPassword)")
    }
}

#Preview {
    RegisterView()
}
