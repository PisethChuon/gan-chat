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
        HStack(spacing: 12) {
            avatar
            
            VStack(alignment: .leading, spacing: 5) {
                HStack(alignment: .firstTextBaseline) {
                    Text(viewModel.name)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Spacer(minLength: 8)
                    
                    Text(viewModel.timestamp)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                
                Text(viewModel.messagePreview)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
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
    List {
        ChatRowView(
            viewModel: ChatRowViewModel.mockChats[0]
        )
    }
    .listStyle(.plain)
}
