//
//  RegisterView.swift
//  GanChat
//
//  Created by chuonpiseth on 7/9/26.
//

import SwiftUI

struct RegisterView: View {
    @State private var viewModel = RegisterViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                VStack (spacing: 4) {
                    Text("Welcome")
                        .font(.title)
                        .bold()
                    
                    Text("Register with your email and password.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 40)
                
                Spacer()
                
                VStack(spacing: 12) {
                    TextField("Username", text: $viewModel.username)
                        .textFieldStyle(.roundedBorder)
                        .autocorrectionDisabled(true)
                    
                    TextField("Email", text: $viewModel.email)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    SecureField("Password", text: $viewModel.password)
                        .textFieldStyle(.roundedBorder)
                    
                    SecureField("Confirm Password", text: $viewModel.confirmPassword)
                        .textFieldStyle(.roundedBorder)
                }
                
                Spacer()
                
                Button {
                    
                } label: {
                    Text("Register")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 4)
                }
                .buttonStyle(.borderedProminent)
                .tint(.primary)
                
                NavigationLink {
                    LoginView()
                } label: {
                    Text("Already have account")
                }
            }
            .padding()
        }
    }
    
}

#Preview {
    NavigationStack {
        RegisterView()
    }
}
