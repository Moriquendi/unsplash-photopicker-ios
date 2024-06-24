//
//  SearchBar.swift
//
//
//  Created by Daniel Choroszucha on 23/06/2022.
//

import Foundation
import SwiftUI
#if os(macOS)
import AppKit
import Cocoa
public typealias NativeView = NSView
#else
import UIKit
public typealias NativeView = UIView
#endif
#if os(macOS)
public typealias NativePlatformViewRepresentable = NSViewRepresentable
public typealias NativePlatformViewControllerRepresentable = NSViewControllerRepresentable
#else
public typealias NativePlatformViewRepresentable = UIViewRepresentable
public typealias NativePlatformViewControllerRepresentable = UIViewControllerRepresentable
#endif

@available(iOS 13.0, *)
public struct SearchBar: View {
    @Binding public var text: String
    public var placeholder: String = ""

    public init(text: Binding<String>, placeholder: String = "") {
        self._text = text
        self.placeholder = placeholder
    }

    public var body: some View {
        Native_SearchBar(text: $text, placeholder: placeholder)
        #if os(iOS)
            // remove default padding for UISearchBar
            .padding(.vertical, -10)
            .padding(.horizontal, -8)
        #endif
    }
}

@available(iOS 13.0, *)
struct Native_SearchBar: PlatformViewRepresentable {
    @Binding var text: String
    var placeholder: String

    #if os(macOS)
    typealias ViewType = NSSearchField
    #else
    typealias ViewType = UISearchBar
    #endif

    func makeView(context: Context) -> ViewType {
        let field = ViewType()
        field.delegate = context.coordinator
        #if os(iOS)
        field.searchBarStyle = .minimal
        field.insetsLayoutMarginsFromSafeArea = false
        #endif
        return field
    }

    func updateView(_ uiView: ViewType, context: Context) {
        #if os(macOS)
        uiView.stringValue = text
        uiView.placeholderString = placeholder
        #else
        uiView.text = text
        uiView.placeholder = placeholder
        #endif
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject {
        let parent: Native_SearchBar

        init(parent: Native_SearchBar) {
            self.parent = parent
        }
    }
}

public protocol PlatformViewRepresentable: NativePlatformViewRepresentable {
    associatedtype ViewType: NativeView

    func makeView(context: Context) -> Self.ViewType
    func updateView(_ uiView: Self.ViewType, context: Self.Context)
}

public extension PlatformViewRepresentable {
    #if os(macOS)
    func makeNSView(context: Self.Context) -> Self.ViewType {
        makeView(context: context)
    }

    func updateNSView(_ uiView: Self.ViewType, context: Self.Context) {
        updateView(uiView, context: context)
    }
    #else
    func makeUIView(context: Self.Context) -> Self.ViewType {
        makeView(context: context)
    }

    func updateUIView(_ uiView: Self.ViewType, context: Self.Context) {
        updateView(uiView, context: context)
    }
    #endif
}

#if os(macOS)
extension Native_SearchBar.Coordinator: NSSearchFieldDelegate {
    func controlTextDidChange(_ obj: Notification) {
        // Update binding.
        parent.text = (obj.object as? NSTextField)?.stringValue ?? ""
    }
}
#else
extension Native_SearchBar.Coordinator: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        parent.text = searchText
    }
}

#endif
