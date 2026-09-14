//
//  ChatRowView.swift
//  GanChat
//
//  Created by chuonpiseth on 14/9/26.
//

import SwiftUI

struct ChatRowView: View {
    var viewModel: ChatRowViewModel
    
    var body: some View {
        
    }
    
    private var avatar: some View {
        ZStack {
            Circle()
                .fill(Color.accentColor.opacity(0.16))
            
            Text(viewModel.initials)
                .font(.headline)
                .foregroundStyle(Color.accentColor)
        }
        .frame(width: 52, height: 52)
        .accessibilityHidden(true)
    }
}

#Preview {
    ChatRowView(
        viewModel: ChatRowViewModel.mockChats[0]
    )
}
