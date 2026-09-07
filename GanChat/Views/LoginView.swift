//
//  LoginView.swift
//  GanChat
//
//  Created by chuonpiseth on 7/9/26.
//

import SwiftUI

struct LoginView: View {
    @State private var viewModel = LoginViewModel()
    
    var body: some View {
        NavigationStack {
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
                    TextField("Email", text: $viewModel.email)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    SecureField("Password", text: $viewModel.password)
                        .textFieldStyle(.roundedBorder)
                }
                
                Spacer()
                
                Button {
                    
                } label: {
                    Text("Log In")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 4)
                }
                .buttonStyle(.borderedProminent)
                .tint(.primary)
                
                NavigationLink {
                    RegisterView()
                } label: {
                    HStack {
                        Text("Don't have an account? Register")
                    }
                    
                }
            }
            .padding()
            .background(Color.background)
        }
    }
}

#Preview {
    NavigationStack {
        LoginView()
    }
}
