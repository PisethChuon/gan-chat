//
//  RegisterView.swift
//  GanChat
//
//  Created by chuonpiseth on 7/9/26.
//

import SwiftUI

struct RegisterView: View {
    @State private var viewModel = RegisterViewModel()
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
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
                    Task {
                        let success = await viewModel.register()
                        if success {
                            dismiss()
                        }
                    }
                } label: {
                    if viewModel.isLoading {
                     ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Register")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 4)
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(.primary)
                .disabled(viewModel.isLoading)
                
                if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
                
                Button {
                    dismiss()
                } label: {
                    Text("Already have account")
                        .foregroundStyle(.secondary)
                    Text("Log In")
                        .foregroundStyle(.primary)
                        .bold()
                }
            }
            .padding()
        }
}

#Preview {
    NavigationStack {
        RegisterView()
    }
}
