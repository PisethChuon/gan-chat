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
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .textContentType(.emailAddress)
                    .submitLabel(.done)
                    .disabled(viewModel.isLoading)
                    .onSubmit {
                        performLogin()
                    }
                
                SecureField("Password", text: $viewModel.password)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.password)
                    .submitLabel(.go)
                    .disabled(viewModel.isLoading)
                    .onSubmit {
                        performLogin()
                    }
            }
            
            Spacer()
            
            Button {
                performLogin()
            } label: {
                Group {
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        Text("Log In")
                            .bold()
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)
            }
            .buttonStyle(.borderedProminent)
            .tint(.primary)
            .disabled(viewModel.isLoading)
            
            if !viewModel.errorMessage.isEmpty {
                Text(viewModel.errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .accessibilityIdentifier("loginErrorMessage")
            }
            
            NavigationLink {
                RegisterView()
            } label: {
                HStack {
                    Text("Don't have an account?")
                        .foregroundStyle(.secondary)
                    Text("Register")
                        .foregroundStyle(.primary)
                        .bold()
                }
            }
            .disabled(viewModel.isLoading)
        }
        .padding()
        .background(Color.background)
        .navigationBarBackButtonHidden()
    }
    
    private func performLogin() {
        Task {
            await viewModel.login()
        }
    }
}

#Preview {
    NavigationStack {
        LoginView()
    }
}
