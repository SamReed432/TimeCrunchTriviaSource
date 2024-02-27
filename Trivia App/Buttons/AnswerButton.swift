//
//  ThemedButton.swift
//  SwiftUIGameOfLife
//

import SwiftUI

public struct ThemedButton: View {
    @available(macOS 13.15, *)
    public var text: String
    public var action: () -> Void

    @available(macOS 13.15, *)
    public init(
        text: String,
        action: @escaping () -> Void
    ) {
        self.text = text
        self.action = action
    }
    public var body: some View {
        HStack {
            Spacer()
            Button(action: action) {
                Text(text)
                    .font(.system(.callout))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(width: 350.0)
                    .padding(.vertical, 20)
            }
            //.background(Color("accent"))
            .overlay(RoundedRectangle(cornerRadius: 15)
                .stroke(Color.white, lineWidth: 4.0)
            )
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .shadow(radius: 2.0)
            Spacer()
        }
        .padding(.vertical, 5)
    }
}

// MARK: Previews
#Preview {
    ThemedButton(text: "Step") { }
}
