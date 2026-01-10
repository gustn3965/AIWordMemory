//
//  EmptyAddView.swift
//  MainHome
//
//  Created by 박현수 on 1/1/25.
//

import SwiftUI
import CommonUI

public struct EmptyAddView: View {

    @Binding var showAddSheet: Bool
    var namespace: Namespace.ID
                
    public var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "text.book.closed")
                .font(.system(size: 48))
                .foregroundStyle(Color.secondary)

            Text("외우고자 하는 단어를 추가해주세요.")
                .font(.headline)
                .foregroundStyle(Color.primary)

            Button {
                showAddSheet.toggle()
            } label: {
                Label("단어 추가", systemImage: "plus")
                    .font(.body.weight(.medium))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.accentColor)
                    .clipShape(Capsule())
            }
            .versioned { view in
                if #available(iOS 26.0, *) {
                    view.matchedTransitionSource(id: "add_write_from_empty", in: namespace)
                } else {
                    view
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .padding(.horizontal, 16)
    }
}

#Preview {
    @Namespace var ns
    return List {
        EmptyAddView(showAddSheet: .constant(false), namespace: ns)
            .listRowSeparator(.hidden)
    }
    .listStyle(.plain)
}
