//
//  SearchBar.swift
//
//
//  Created by Daniel Choroszucha on 23/06/2022.
//

import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    var placeholder: String = ""

    init(text: Binding<String>, placeholder: String = "") {
        self._text = text
        self.placeholder = placeholder
    }

    var body: some View {
        NSSearchBar(text: $text, placeholder: placeholder)
            .padding(.horizontal, 4)
    }
}

struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        SearchBar(text: .constant(""))
    }
}

struct NSSearchBar: NSViewRepresentable {
    typealias NSViewType = NSSearchField

    @Binding var text: String
    var placeholder: String

    func makeNSView(context: Context) -> NSSearchField {
        let field = NSSearchField()
        field.delegate = context.coordinator
        return field
    }

    func updateNSView(_ nsView: NSSearchField, context: Context) {
        nsView.stringValue = text
        nsView.placeholderString = placeholder
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject {
        let parent: NSSearchBar

        init(parent: NSSearchBar) {
            self.parent = parent
        }
    }
}

extension NSSearchBar.Coordinator: NSSearchFieldDelegate {
    func controlTextDidChange(_ obj: Notification) {
        // Update binding.
        parent.text = (obj.object as? NSTextField)?.stringValue ?? ""
    }
}
