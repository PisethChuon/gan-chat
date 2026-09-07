//
//  LoginView.swift
//  GanChat
//
//  Created by chuonpiseth on 7/9/26.
//

import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    
    var body: some View {
            VStack(spacing: 16) {
                VStack(spacing: 4) {
                    Text("Welcome Back")
                        .font(.title)
                        .bold()
                    
                    Text("Log in with your email and password.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 40)
                
                Spacer()
                
                VStack(spacing: 12) {
                    TextField("Email", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(.roundedBorder)
                }
                
                Spacer()
                
                Button {
                    login()
                } label: {
                    Text("Log In")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 4)
                }
                .buttonStyle(.borderedProminent)
                .tint(.primary)
            }
            .padding()
            .background(Color.background)
        }
        
        func login() {
            print("email: \(email) | password: \(password)")
        }
}

#Preview {
    LoginView()
}
